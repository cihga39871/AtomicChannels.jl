# AtomicChannels

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cihga39871.github.io/AtomicChannels.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cihga39871.github.io/AtomicChannels.jl/dev/)
[![Build Status](https://github.com/cihga39871/AtomicChannels.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cihga39871/AtomicChannels.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/cihga39871/AtomicChannels.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cihga39871/AtomicChannels.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/A/AtomicChannels.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/A/AtomicChannels.html)

AtomicChannels provides thread-safe, lock-free and task-free channel/queue for Julia.

## Features

- `AtomicChannel{T}`: fast lock-free multi-producer multi-consumer (MPMC) channel, implemented as a ring buffer with atomic operations to ensure thread safety.
  - Faster than `Base.Channel`.
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

```julia
using AtomicChannels

chnl = AtomicChannel{Int}(2)
put!(chnl, 1)
put!(chnl, 2)

take!(chnl)          # 1
trytake!(chnl)       # 2
trytake!(chnl)       # nothing
```

### ReusePool

```julia
using AtomicChannels

pool = ReusePool(() -> Vector{Int}(undef, 1024), 4, x -> fill!(x, 0))

buf = acquire!(pool)
buf[1] = 42
release!(pool, buf)
```

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
