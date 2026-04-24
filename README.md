# AtomicChannels

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cihga39871.github.io/AtomicChannels.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cihga39871.github.io/AtomicChannels.jl/dev/)
[![Build Status](https://github.com/cihga39871/AtomicChannels.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cihga39871/AtomicChannels.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/cihga39871/AtomicChannels.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cihga39871/AtomicChannels.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/A/AtomicChannels.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/A/AtomicChannels.html)

AtomicChannels provides thread-safe, lock-free and task-free channel/queue for Julia.

## Features

- `AtomicChannel{T}`: fast lock-free multi-producer multi-consumer (MPMC) channel, implemented as a ring buffer with atomic operations to ensure thread safety.
  - Up to 20 times faster than `Base.Channel` in contention scenarios ([details in benchmark section](#Benchmark)).
  - Base channel compatibility helpers (`isready`, `wait`, `fetch`, `empty!`, iteration).
- `ReusePool{T}`: reusable object pool built on top of `AtomicChannel`
- Blocking and non-blocking APIs

## Installation

```julia
using Pkg
Pkg.add("AtomicChannels")
```

## Quick start

### AtomicChannel

The core usage of `AtomicChannel` is similar to a buffered `Base.Channel`. 

- Creation: `AtomicChannel{eltype}(channel_size)`
- Blocking operations:
  - `put!(::AtomicChannel{T}, item::T)`: push item to channel
  - `take!(::AtomicChannel{T})`: take the next available item
- Non-blocking operations:
  - `tryput!(::AtomicChannel{T}, item::T)`: returns `Bool`
  - `trytake!(::AtomicChannel{T})`: returns item or `nothing`

```julia
using AtomicChannels

chnl = AtomicChannel{Int}(2)  # size=2, type=Int
put!(chnl, 1)
tryput!(chnl, 2)

take!(chnl)          # 1
trytake!(chnl)       # 2
trytake!(chnl)       # nothing
```

### ReusePool

ReusePool is a lightweight object pool implemented on top of AtomicChannel. 

The pool allows efficient reuse of objects, reducing the overhead of frequent object creation and destruction.

- Constructor:
  - `ReusePool{T}(create::Function, size::Int = 1, reset::Function = identity)`
    - `create` has to be a thread-safe function that creates a new instance of `T`.
    - `reset` (optional) should be a function to in-place edit an item that is put back in the pool.
- Blocking operations:
  - `take!(::ReusePool)`: take an object, blocks when empty
  - `put!(::ReusePool, item)`: reset and return an object, blocks when full
- Non-blocking operations:
  - `acquire!(::ReusePool)`: take an object if available, otherwise create a new one
  - `release!(ReusePool{T}, item::T)`: try to return an object to the pool, returns `true` on success

```julia
using AtomicChannels

pool = ReusePool(() -> Vector{Int}(undef, 1024), 4, x -> fill!(x, 0))

buf = acquire!(pool)
buf[1] = 42
release!(pool, buf)
```

## Benchmark

The benchmark reports in [benchmark](benchmark) compare `AtomicChannel` with `Base.Channel` on Linux (AMD Ryzen Threadripper PRO 7985WX, 128 cores).

Method summary:

- Benchmark target: MPMC put/take throughput (`items=50000`) for `AtomicChannel` vs `Base.Channel`.
- Metric: speedup is computed as `Channel ÷ AtomicChannel` (elapsed time in ms).
- Three scenario groups are measured:
  - Case 1: low-capacity contention (`capacity=4` or `1`).
  - Case 2: higher-capacity, low data contention (`capacity=256`).
  - Case 3: varying worker/task counts at `capacity=256`.

Representative speedups from the latest `mpmc_result` files:

| Julia | Case 1: 64 threads, 64 workers, cap=4 | Case 2: 32 threads, 32 workers, cap=256 | Case 3: 32 threads, 256 workers, cap=256 |
|---|---:|---:|---:|
| 1.12.6 | 23.161x | 1.644x | 12.106x |
| 1.11.9 | 12.383x | 2.399x | 1.811x |
| 1.10.11 | 22.519x | 2.810x | 1.800x |
| 1.9.4 | 9.931x | 3.556x | 1.849x |
| 1.8.5 | 2.622x | 1.551x | 1.737x |

Notes:

- Most tested scenarios are faster than `Base.Channel`; drastically faster with heavy task switch and multiple concurrent data operations.
- Time: 2026-04-23 14:07:10; package version 1.0.0.
- Use the raw reports below for full tables and environment details.

Raw benchmark reports:

- [benchmark/mpmc_result__1.0.0-DEV2__1.12.6.md](benchmark/mpmc_result__1.0.0-DEV2__1.12.6.md)
- [benchmark/mpmc_result__1.0.0-DEV2__1.11.9.md](benchmark/mpmc_result__1.0.0-DEV2__1.11.9.md)
- [benchmark/mpmc_result__1.0.0-DEV2__1.10.11.md](benchmark/mpmc_result__1.0.0-DEV2__1.10.11.md)
- [benchmark/mpmc_result__1.0.0-DEV2__1.9.4.md](benchmark/mpmc_result__1.0.0-DEV2__1.9.4.md)
- [benchmark/mpmc_result__1.0.0-DEV2__1.8.5.md](benchmark/mpmc_result__1.0.0-DEV2__1.8.5.md)

### Reproduce Benchmark

Run from the repository root:

```bash
cd AtomicChannels.jl

julia +1.8 --project benchmark/mpmc.jl
julia +1.9 --project benchmark/mpmc.jl
julia +1.10 --project benchmark/mpmc.jl
julia +1.11 --project benchmark/mpmc.jl
julia +1.12 --project benchmark/mpmc.jl
```

Each run generates a report to the [benchmark](benchmark) directory.

## Documentation

- Stable docs: https://cihga39871.github.io/AtomicChannels.jl/stable/
- Dev docs: https://cihga39871.github.io/AtomicChannels.jl/dev/

Build docs locally:

```julia
cd("docs")
using Pkg
Pkg.instantiate()
include("make.jl")
```
