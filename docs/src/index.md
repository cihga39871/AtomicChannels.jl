```@meta
CurrentModule = AtomicChannels
```

# AtomicChannels

AtomicChannels provides lock-free concurrent data structures for Julia:

- `AtomicChannel`: fast multi-producer multi-consumer (MPMC) channel, implemented as a ring buffer with atomic operations to ensure thread safety
- `ReusePool`: object pool built on top of `AtomicChannel`

## Installation

```julia
using Pkg
Pkg.add("AtomicChannels")
```

## Quick Start

```julia
using AtomicChannels

chnl = AtomicChannel{Int}(2)
put!(chnl, 1)
put!(chnl, 2)

x = take!(chnl)      # 1
y = trytake!(chnl)   # 2
z = trytake!(chnl)   # nothing
```

```julia
pool = ReusePool(() -> Vector{Int}(undef, 16), 4, x -> fill!(x, 0))
buf = acquire!(pool)
buf[1] = 123
release!(pool, buf)
```

## Contents

- [Benchmark](benchmark.md)
- [AtomicChannel](atomic-channel.md)
- [ReusePool](reuse-pool.md)
- [API Reference](api.md)
- [Changelog](changelog.md)

```@index
```
