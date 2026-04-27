```@meta
CurrentModule = AtomicChannels
```

# Changelog

## 1.0.1

- Change: all `yield()` are wrapped in try catch block now, in case an outer task sending InterruptException to the task that is in `yield()`.

No performance degradation detected.

## 1.0.0

- Release.
- Change docs.

## 1.0.0-DEV2

### Added

- `AtomicChannel` and `ReusePool` documentation pages.
- MPMC benchmark workflow and versioned benchmark reports.
- Benchmark documentation page in [Benchmark](benchmark.md).
- Changelog page in docs.

### Changed

- Improved MPMC throughput across Julia versions (1.8 through 1.12) under most tested contention patterns.
- `AtomicChannel` token acquisition strategy now uses adaptive spin/yield behavior for better cross-version scheduler performance.
- Updated benchmark summaries in README and docs.
