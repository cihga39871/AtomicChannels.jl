```@meta
CurrentModule = AtomicChannels
```

# ReusePool

ReusePool is a lightweight object pool implemented on top of AtomicChannel.

It is useful when object construction is expensive and objects can be reset and reused safely.

## Create a pool

```julia
using AtomicChannels

create_obj() = Dict{Symbol, Int}(:count => 0)
reset_obj!(obj) = (obj[:count] = 0; obj)

pool = ReusePool(create_obj, 8, reset_obj!)
```

Constructor arguments:

- `create`: creates a new object
- `size`: maximum number of retained objects
- `reset`: in-place reset function used when putting/releasing objects back

## Blocking API

- `take!(pool)`: take an object, blocks when empty
- `put!(pool, obj)`: reset and return an object, blocks when full

## Non-blocking API

- `acquire!(pool)`: take an object if available, otherwise create a new one
- `release!(pool, obj)`: try to return an object, returns `true` on success
- `fill!(pool)`: pre-fill pool to capacity using `create`

### Example

```julia
pool = ReusePool(() -> Vector{Int}(undef, 1024), 4, x -> fill!(x, 0))

buf = acquire!(pool)    # get pooled buffer or create new
buf[1] = 42
ok = release!(pool, buf)
```

## Display

`show(pool)` prints a compact occupancy summary, for example:

- `ReusePool{Vector{Int64}} with 2/4 items`
