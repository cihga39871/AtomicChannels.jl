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

| Julia | Case 1: 64 threads, 64 workers, cap=4 | Case 2: 64 threads, 64 workers, cap=256 | Case 3: 32 threads, 256 workers, cap=256 |
|---|---:|---:|---:|
| 1.12.6 | 33.8x | 3.023x | 27.638x |
| 1.11.9 | 9.751x | 4.4x | 2.165x |
| 1.10.11 | 13.103x | 4.876x | 2.288x |
| 1.9.4 | 17.579x | 6.155x | 2.367x |
| 1.8.5 | 6.311x | 1.994x | 1.709x |

Conclusion:

- `AtomicChannel` are faster than `Base.Channel` in most test scenarios; drastically faster with heavy task switch and multiple concurrent data operations.

## Raw Reports

- [Julia 1.12.6](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.12.6.md)
- [Julia 1.11.9](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.11.9.md)
- [Julia 1.10.11](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.10.11.md)
- [Julia 1.9.4](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.9.4.md)
- [Julia 1.8.5](https://github.com/cihga39871/AtomicChannels.jl/blob/main/benchmark/mpmc_result__1.8.5.md)

## Reproduce

Run from repository root:

```bash
julia --project benchmark/mpmc.jl
```

Or pin the Julia version with `juliaup`:

```bash
julia +1.12 --project benchmark/mpmc.jl
julia +1.11 --project benchmark/mpmc.jl
julia +1.10 --project benchmark/mpmc.jl
julia +1.9 --project benchmark/mpmc.jl
julia +1.8 --project benchmark/mpmc.jl
```

Each run generates a versioned report in `benchmark/`.
