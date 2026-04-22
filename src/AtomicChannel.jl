"""
    mutable struct AtomicCell{T}
        state::Threads.Atomic{UInt8}
        value::Base.RefValue{Union{T, Nothing}}
    end

A cell in the `AtomicChannel`. The `state` can be empty (0), filled (1), or busy (2; being written/cleared). The `value` field holds the item when the cell is filled or `nothing` when it is empty.
"""
mutable struct AtomicCell{T}
    state::Threads.Atomic{UInt8}  # 0 = CELL_EMPTY, 1 = CELL_FILLED, 2 = CELL_BUSY (being written/cleared)
    value::Base.RefValue{Union{T, Nothing}}
end

const CELL_EMPTY  = 0x00
const CELL_FILLED = 0x01
const CELL_BUSY   = 0x02

"""
    AtomicChannel{T<:Any}(capacity::Int)
    AtomicChannel(capacity::Int) -> AtomicChannel{Any}

A thread-safe, lock-free and task-free channel/queue implementation for type `T`. 

It supports concurrent producers and consumers with blocking and non-blocking APIs. The channel is implemented as a ring buffer with atomic operations to ensure thread safety.

- `capacity` specifies the maximum number of items the channel can hold. It must be greater than 0.

# Examples
```jldoctest
julia> chnl = AtomicChannel{Int}(2)
AtomicChannel{Int64} with 0/2 items
  head = 0, tail = 0, free = 2
  slots = [..]

julia> put!(chnl, 1)
AtomicChannel{Int64} with 1/2 items
  head = 0, tail = 1, free = 1
  slots = [X.]

julia> put!(chnl, 2)
AtomicChannel{Int64} with 2/2 items
  head = 0, tail = 2, free = 0
  slots = [XX]

julia> tryput!(chnl, 3)  # returns false since the chnl is full
false

julia> take!(chnl)  # returns 1
1

julia> take!(chnl)  # returns 2
2

julia> trytake!(chnl)  # returns nothing since the chnl is empty
```
"""
struct AtomicChannel{T} <: AbstractChannel{T}
    head::Threads.Atomic{Int}      # index from 0 for next take slot, will reset to rem of capacity if too large
    tail::Threads.Atomic{Int}      # index from 0 for next put slot, will reset to rem of capacity if too large
    n_filled::Threads.Atomic{Int}  # count of items currently in the chnl
    n_free::Threads.Atomic{Int}    # count of free slots currently in the chnl
    capacity::Int                  # total capacity of the chnl
    cells::Vector{AtomicCell{T}}     # pre-allocated cells for storing items and their states

    function AtomicChannel{T}(head::Threads.Atomic{Int}, tail::Threads.Atomic{Int}, n_filled::Threads.Atomic{Int},
                     n_free::Threads.Atomic{Int}, capacity::Int, cells::Vector{AtomicCell{T}}) where T<:Any
        @assert capacity > 0 "AtomicChannel: size must be greater than 0"
        @assert capacity < (typemax(Int) >> 2) "AtomicChannel: size must be less than `typemax(Int) >> 2`"  # restricted by the ring index implementation `_acquire_ring_index!`
        return new{T}(head, tail, n_filled, n_free, capacity, cells)
    end
end

function AtomicChannel{T}(capacity::Int) where T<:Any
    cells = Vector{AtomicCell{T}}(undef, capacity)
    for i in 1:capacity
        cells[i] = AtomicCell{T}(Threads.Atomic{UInt8}(0), Ref{Union{T, Nothing}}(nothing))
    end

    return AtomicChannel{T}(
        Threads.Atomic{Int}(0),
        Threads.Atomic{Int}(0),
        Threads.Atomic{Int}(0),
        Threads.Atomic{Int}(capacity),
        capacity,
        cells,
    )
end

function AtomicChannel(capacity::Int)
    return AtomicChannel{Any}(capacity)
end

# Acquire a token from the counter, blocking (spinning/yielding) until one is available.
@inline function _acquire_token!(counter::Threads.Atomic{Int})
    while true
        old = counter[]
        if old == 0
            yield()
            continue
        end
        if Threads.atomic_cas!(counter, old, old - 1) == old
            return
        end
        yield()
    end
end

# Try to acquire a token from the counter, returning `true` if successful or `false` immediately when no tokens are available.
@inline function _try_acquire_token!(counter::Threads.Atomic{Int})
    old = counter[]
    while old > 0
        if Threads.atomic_cas!(counter, old, old - 1) == old
            return true
        end
        old = counter[]
    end
    return false
end

@inline function _acquire_ring_index!(idx::Threads.Atomic{Int}, capacity::Int)
    pos = Threads.atomic_add!(idx, 1)

    # `ctlz_int` returns the number of `leading_zeros`,
    # so this checks if pos >= 2^(wordsize-3) = 2^61 for 64-bit Int
    if Core.Intrinsics.ctlz_int(pos) < 3
        # The index can grow without bound, so we reset it to the remainder after wrapping around.
        while true
            old = idx[]
            new = old % capacity
            if Threads.atomic_cas!(idx, old, new) == old || Core.Intrinsics.ctlz_int(old) >= 3
                # Successfully reset the index or another thread has already done it
                break
            end
            yield()
        end
    end
    return pos % capacity + 1
end

# const COUNT_CELL_CONFLICT = Threads.Atomic{Int}(0)  # for testing contention scenarios

"""
    put!(chnl::AtomicChannel{T}, item::T) where T<:Any

Puts an item into the chnl. If the chnl is full, the function is blocked until space is available.

See also: [`take!`](@ref) to take an item from the chnl (blocked when empty).

See also: [`tryput!`](@ref) and [`trytake!`](@ref) for non-blocking versions of put and take.
"""
function Base.put!(chnl::AtomicChannel{T}, item::T) where T<:Any
    _acquire_token!(chnl.n_free)
    slot = _acquire_ring_index!(chnl.tail, chnl.capacity)
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_EMPTY, CELL_BUSY) != CELL_EMPTY
        # Wait for the consumer to finish clearing this slot.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    cell.value[] = item
    cell.state[] = CELL_FILLED
    Threads.atomic_add!(chnl.n_filled, 1)
    return chnl
end

"""
    tryput!(chnl::AtomicChannel{T}, item::T) where T<:Any
    tryput!(reset_func::Base.Callable, chnl::AtomicChannel{T}, item::T) where T<:Any

Non-blocking variant of `put!`.

The `reset_func` should in-place edit `item`. It is applied to the item only when the item can be inserted into the chnl.

Returns `true` if `item` was inserted, or `false` immediately when the chnl is full.
"""
function tryput!(chnl::AtomicChannel{T}, item::T) where T<:Any
    _try_acquire_token!(chnl.n_free) || return false

    slot = _acquire_ring_index!(chnl.tail, chnl.capacity)
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_EMPTY, CELL_BUSY) != CELL_EMPTY
        # The slot for this tail ticket can lag briefly behind free token updates.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    cell.value[] = item
    cell.state[] = CELL_FILLED
    Threads.atomic_add!(chnl.n_filled, 1)
    return true
end

function tryput!(reset_func::Base.Callable, chnl::AtomicChannel{T}, item::T) where T<:Any
    _try_acquire_token!(chnl.n_free) || return false

    slot = _acquire_ring_index!(chnl.tail, chnl.capacity)
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_EMPTY, CELL_BUSY) != CELL_EMPTY
        # The slot for this tail ticket can lag briefly behind free token updates.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    reset_func(item)
    cell.value[] = item
    cell.state[] = CELL_FILLED
    Threads.atomic_add!(chnl.n_filled, 1)
    return true
end

"""
    take!(chnl::AtomicChannel{T}) where T<:Any

Takes an item from the chnl. If the chnl is empty, the function is blocked until an item is available.

Edge case:
 - If you put a `nothing` into the chnl, it will be treated as a valid item and returned.

See also: [`put!`](@ref) to put an item into the chnl (blocked when full).

See also: [`tryput!`](@ref) and [`trytake!`](@ref) for non-blocking versions of put and take.
"""
function Base.take!(chnl::AtomicChannel{T}) where T<:Any
    _acquire_token!(chnl.n_filled)
    slot = _acquire_ring_index!(chnl.head, chnl.capacity)
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_FILLED, CELL_BUSY) != CELL_FILLED
        # Wait for the producer to finish writing this slot.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    item = cell.value[]
    cell.value[] = nothing
    cell.state[] = CELL_EMPTY
    Threads.atomic_add!(chnl.n_free, 1)
    return item::T
end

"""
    trytake!(chnl::AtomicChannel{T}) where T<:Any

Non-blocking variant of `take!`.

Returns an item from the chnl when available, or `nothing` immediately when the chnl is empty.

Edge case:
 - If you put a `nothing` into the chnl, it will be treated as a valid item and returned.
"""
function trytake!(chnl::AtomicChannel{T}) where T<:Any
    _try_acquire_token!(chnl.n_filled) || return nothing

    slot = _acquire_ring_index!(chnl.head, chnl.capacity)
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_FILLED, CELL_BUSY) != CELL_FILLED
        # The slot for this head ticket can lag briefly behind filled token updates.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    item = cell.value[]
    cell.value[] = nothing
    cell.state[] = CELL_EMPTY
    Threads.atomic_add!(chnl.n_free, 1)
    return item::T
end

"""
    fetch(chnl::AtomicChannel{T}) where T<:Any

Waits for and returns (without removing) the first available item from the AtomicChannel.
"""
function Base.fetch(chnl::AtomicChannel{T}) where T<:Any
    _acquire_token!(chnl.n_filled)
    slot = chnl.head[] % chnl.capacity + 1
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_FILLED, CELL_BUSY) != CELL_FILLED
        # Wait for the producer to finish writing this slot.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    item = cell.value[]
    cell.state[] = CELL_FILLED  # set back to filled state without clearing the value
    Threads.atomic_add!(chnl.n_filled, 1)  # restore the filled token since we're not actually taking the item
    return item::T
end

@inline Base.length(chnl::AtomicChannel{<:Any}) = chnl.capacity

# API compatibility with Base.Channel
@inline Base.isopen(chnl::AtomicChannel{<:Any}) = true
@inline Base.close(chnl::AtomicChannel{<:Any}) = nothing
@inline Base.close(chnl::AtomicChannel{<:Any}, excp::Exception) = nothing

@inline Base.isbuffered(chnl::AtomicChannel{<:Any}) = true
@inline Base.check_channel_state(chnl::AtomicChannel{<:Any}) = nothing

@inline Base.isready(chnl::AtomicChannel{<:Any}) =  chnl.n_filled[] > 0
@inline Base.isempty(chnl::AtomicChannel{<:Any}) = chnl.n_filled[] == 0
@inline Base.n_avail(chnl::AtomicChannel{<:Any}) = chnl.n_filled[]

@static if isdefined(Base, :isfull)
    @inline Base.isfull(chnl::AtomicChannel{<:Any}) = chnl.n_free[] == 0
else
    @inline isfull(chnl::AtomicChannel{<:Any}) = chnl.n_free[] == 0
end

@inline Base.lock(chnl::AtomicChannel{<:Any}) = nothing
@inline Base.lock(f::Function, chnl::AtomicChannel{<:Any}) = f()
@inline Base.unlock(chnl::AtomicChannel{<:Any}) = nothing

Base.eltype(::Type{AtomicChannel{T}}) where {T} = T

function Base.wait(chnl::AtomicChannel{T}) where T<:Any
    _acquire_token!(chnl.n_filled)
    Threads.atomic_add!(chnl.n_filled, 1)
    return nothing
end

function Base.empty!(chnl::AtomicChannel{T}) where T<:Any
    while chnl.n_filled[] > 0
        trytake!(chnl)  # clear out all items
    end
    return chnl
end

function Base.iterate(chnl::AtomicChannel{T}, state=nothing) where T<:Any
    _try_acquire_token!(chnl.n_filled) || return nothing

    slot = _acquire_ring_index!(chnl.head, chnl.capacity)
    cell = @inbounds chnl.cells[slot]

    while Threads.atomic_cas!(cell.state, CELL_FILLED, CELL_BUSY) != CELL_FILLED
        # The slot for this head ticket can lag briefly behind filled token updates.
        # Threads.atomic_add!(COUNT_CELL_CONFLICT, 1)  # for testing contention scenarios
        yield()
    end

    item = cell.value[]
    cell.value[] = nothing
    cell.state[] = CELL_EMPTY
    Threads.atomic_add!(chnl.n_free, 1)
    return item::T, nothing
end

Base.IteratorSize(::Type{<:AtomicChannel}) = Base.SizeUnknown()

function Base.show(io::IO, cell::AtomicCell{T}) where T<:Any
    state = cell.state[]
    value = cell.value[]
    if state == CELL_EMPTY
        print(io, "AtomicCell{", T, "}(empty)")
    elseif state == CELL_FILLED
        print(io, "AtomicCell{", T, "}(full, value=", value, ")")
    else
        print(io, "AtomicCell{", T, "}(busy)")
    end
end

function Base.show(io::IO, chnl::AtomicChannel{T}) where T<:Any
    filled = chnl.n_filled[]
    print(io, "AtomicChannel{", T, "}(", filled, "/", chnl.capacity, ")")
end

function Base.show(io::IO, ::MIME"text/plain", chnl::AtomicChannel{T}) where T<:Any
    filled = chnl.n_filled[]
    free = chnl.n_free[]
    lock(io)
    try
        print(io, "AtomicChannel{", T, "} with ", filled, "/", chnl.capacity, " items")
        print(io, "\n  head = ", chnl.head[], ", tail = ", chnl.tail[], ", free = ", free)

        if !get(io, :compact, false)
            # print slots in one line
            max_width = displaysize(io)[2]
            max_slots_to_show = max(0, max_width - 12)  # leave space for the header info
            print(io, "\n  slots = [")
            if chnl.capacity > max_slots_to_show
                print(io, " ... too many items ... ")
            else
                for i in 1:chnl.capacity
                    state = @inbounds chnl.cells[i].state[]
                    print(io, state == CELL_FILLED ? 'X' : '.')
                end
            end
            print(io, "]")
        end
    finally
        unlock(io)
    end
end
