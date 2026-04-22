```@meta
CurrentModule = AtomicChannels
```

# AtomicChannel

AtomicChannel is a bounded, lock-free, multi-producer multi-consumer channel built on atomic operations.

## Create a channel

```julia
using AtomicChannels

chnl = AtomicChannel{Int}(4)
```

The channel capacity is fixed. Producers block on `put!` when full, and consumers block on `take!` when empty.

## Core operations

- `put!(chnl, item)`: blocking push
- `take!(chnl)`: blocking pop
- `tryput!(chnl, item)`: non-blocking push, returns `Bool`
- `trytake!(chnl)`: non-blocking pop, returns item or `nothing`

### Example

```julia
chnl = AtomicChannel{Int}(2)

put!(chnl, 10)
put!(chnl, 20)

ok = tryput!(chnl, 30)  # false, channel is full
x = take!(chnl)         # 10
y = trytake!(chnl)      # 20
z = trytake!(chnl)      # nothing
```

## Compatibility helpers

AtomicChannel implements common Base channel-style utilities:

- state and capacity: `isready`, `isempty`, `isfull`, `length`, `Base.n_avail`
- lifecycle compatibility: `isopen`, `close`
- waiting and peeking: `wait`, `fetch`
- clearing and iteration: `empty!`, `iterate`, `collect`

## Notes

- `trytake!` uses `nothing` to mean "empty". If item can be `nothing`, prefer blocking `take!` when ambiguity matters.
- Internal ring indices are periodically wrapped to avoid long-running counter growth.
