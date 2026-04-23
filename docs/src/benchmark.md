```@meta
CurrentModule = AtomicChannels
```

# Benchmark

The benchmark compares `AtomicChannel` with `Base.Channel` using a multi-producer multi-consumer (MPMC) workload.

## Method Summary

- Benchmark target: put/take throughput with `items=50000`
- Metric: speedup is computed as `Channel ÷ AtomicChannel` (elapsed time in ms).
- Scenario groups:
  - Case 1: low-capacity contention (`capacity=4` or `1`)
  - Case 2: higher-capacity, lower data contention (`capacity=256`)
  - Case 3: varying worker/task counts (`capacity=256`)

## Representative Results

Representative speedups are shown below from the latest report for each Julia version.

| Julia | Case 1: 64 threads, 64 workers, cap=4 | Case 2: 32 threads, 32 workers, cap=256 | Case 3: 32 threads, 256 workers, cap=256 |
|---|---:|---:|---:|
| 1.12.6 | 23.161x | 1.644x | 12.106x |
| 1.11.9 | 12.383x | 2.399x | 1.811x |
| 1.10.11 | 22.519x | 2.810x | 1.800x |
| 1.9.4 | 9.931x | 3.556x | 1.849x |
| 1.8.5 | 2.622x | 1.551x | 1.737x |

Notes:

- Most tested scenarios are faster than `Base.Channel`.
- Some scheduler/contention mixes can still fall below parity.

## Raw Reports

- [Julia 1.12.6](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.0.0-DEV2__1.12.6.md)
- [Julia 1.11.9](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.0.0-DEV2__1.11.9.md)
- [Julia 1.10.11](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.0.0-DEV2__1.10.11.md)
- [Julia 1.9.4](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.0.0-DEV2__1.9.4.md)
- [Julia 1.8.5](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.0.0-DEV2__1.8.5.md)

## Reproduce

Run from repository root:

```bash
julia --project benchmark/mpmc.jl
```

Or pin the Julia version with `juliaup`:

```bash
julia +1.8 --project benchmark/mpmc.jl
julia +1.9 --project benchmark/mpmc.jl
julia +1.10 --project benchmark/mpmc.jl
julia +1.11 --project benchmark/mpmc.jl
julia +1.12 --project benchmark/mpmc.jl
```

Each run generates a versioned report in `benchmark/`.
