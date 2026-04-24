```@meta
CurrentModule = AtomicChannels
```

# ReusePool

ReusePool is a lightweight object pool implemented on top of AtomicChannel. 

The pool allows efficient reuse of objects, reducing the overhead of frequent object creation and destruction.

The pool is thread-safe and can be used in concurrent environments.

## Create a pool

```julia
using AtomicChannels

create_obj() = Dict{Symbol, Int}(:count => 0)
reset_obj!(obj) = (obj[:count] = 0; obj)

pool = ReusePool(create_obj, 8, reset_obj!)
```

Constructor `ReusePool{T}(create::Function, size::Int = 1, reset::Function = identity)`:

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

## Other functions

- `fill!(reuse_pool::ReusePool{T})`: fill the pool to its maximum size by creating new items using the `create` function.
