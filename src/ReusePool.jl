
"""
    ReusePool(create::Function, size::Int = 1, reset::Function = identity)
    ReusePool{T}(create::Function, size::Int = 1, reset::Function = identity)

A thread-safe and reusable pool of objects of type `T`. The pool allows for efficient reuse of objects, reducing the overhead of creating and destroying objects frequently. The pool is thread-safe and can be used in concurrent environments.

Once a `ReusePool` is created, it comes with one instance of `T` created by the `create` function. The pool can hold up to `size` instances of `T`. When an item is taken from the pool, it is removed from the pool until it is put back.

# Fields

- `create::Function`: A function that creates a new instance of `T`. This function must be thread-safe and should return a new instance of `T` each time it is called.
- `reset::Function`: A function that resets an instance of `T` to a clean state. Defaults to `identity`. This function must edit the item in place and should not return a new instance.
- `chnl::AtomicChannel{T}`: An atomic lock-free channel that holds the reusable objects.

# API

- Blocking: `take!(pool)`, `put!(pool, item)`
- Non-blocking: `acquire!(pool)`, `release!(pool, item)`, `fill!(pool)`
"""
struct ReusePool{T<:Any}
    create::Base.Callable   # A function to create new instances of T
    reset::Base.Callable    # A function to reset instances of T (defaults to identity)
    chnl::AtomicChannel{T}  # An atomic lock-free channel to hold the reusable objects
    function ReusePool{T}(create::Base.Callable, reset::Base.Callable, chnl::AtomicChannel{T}) where T<:Any
        return new{T}(create, reset, chnl)
    end
end

function ReusePool(create::Base.Callable, size::Int = 1, reset::Base.Callable = identity)
    @assert size > 0 "ReusePool: size must be greater than 0"
    data = create()
    @assert !isnothing(data) "ReusePool: create function must not return nothing"
    T = typeof(data)
    chnl = AtomicChannel{T}(size)
    put!(chnl, data)
    return ReusePool{T}(create, reset, chnl)
end

function ReusePool{T}(create::Base.Callable, size::Int = 1, reset::Base.Callable = identity) where T<:Any
    @assert size > 0 "ReusePool: size must be greater than 0"
    data = create()
    @assert isa(data, T) "ReusePool: create must return type $T"
    chnl = AtomicChannel{T}(size)
    put!(chnl, data)
    return ReusePool{T}(create, reset, chnl)
end

"""
    take!(reuse_pool::ReusePool{T}) where T<:Any

Takes an item from the chnl. If the chnl is empty, the function is blocked until an item is available.

See also: [`put!`](@ref) to reset and put an item back to the chnl (blocked when full).

See also: [`acquire!`](@ref) and [`release!`](@ref) for non-blocking versions of take and put.
"""
function Base.take!(reuse_pool::ReusePool{<:Any})
    return take!(reuse_pool.chnl)
end

"""
    put!(reuse_pool::ReusePool{T}, item::T) where T<:Any

Puts an item back into the chnl after resetting it. If the chnl is full, the function is blocked until space is available.

See also: [`take!`](@ref) to take an item from the chnl (blocked when empty).

See also: [`acquire!`](@ref) and [`release!`](@ref) for non-blocking versions of take and put.
"""
function Base.put!(reuse_pool::ReusePool{T}, item::T) where T<:Any
    reuse_pool.reset(item)
    put!(reuse_pool.chnl, item)
end

"""
    fill!(reuse_pool::ReusePool{T}) where T<:Any

Fills the chnl to its maximum size by creating new items using the `create` function. This function requires locking to ensure thread safety when filling the chnl.
"""
function Base.fill!(reuse_pool::ReusePool{T}) where T<:Any
    while !isfull(reuse_pool.chnl)
        tryput!(reuse_pool.chnl, reuse_pool.create()) || break
    end
    reuse_pool
end

"""
    release!(reuse_pool::ReusePool{T}, item::T) where T<:Any

Releases an item back to the chnl without blocking. If the chnl is full, the item is discarded.
Return `true` if the item was successfully released back to the chnl, or `false` if the item was discarded because the chnl is full.

See also: [`acquire!`](@ref) to get an item from the chnl without blocking.

See also: [`take!`](@ref) and [`put!`](@ref) for blocking versions.
"""
function release!(reuse_pool::ReusePool{T}, item::T) where T<:Any
    return tryput!(reuse_pool.reset, reuse_pool.chnl, item)
end

"""
    acquire!(reuse_pool::ReusePool{T}) where T<:Any

Gets an item from the chnl without blocking. If the chnl is empty, a new item is created using the `create` function.

See also: [`release!`](@ref) to release an item back to the chnl without blocking.

See also: [`take!`](@ref) and [`put!`](@ref) for blocking versions.
"""
function acquire!(reuse_pool::ReusePool{<:Any})
    item = trytake!(reuse_pool.chnl)
    return item === nothing ? reuse_pool.create() : item
end

function Base.show(io::IO, reuse_pool::ReusePool{T}) where T<:Any
    filled = reuse_pool.chnl.n_filled[]
    capacity = reuse_pool.chnl.capacity
    print(io, "ReusePool{", T, "} with ", filled, "/", capacity, " items")
end
