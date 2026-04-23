
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-04-23 14:07:10  
AtomicChannels.jl Version 1.0.0-DEV2  
Julia Version 1.8.5  
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)  
Platform Info:  
  OS: Linux (x86_64-linux-gnu)  
  CPU: 128 × AMD Ryzen Threadripper PRO 7985WX 64-Cores  
  WORD_SIZE: 64  
  LIBM: libopenlibm  
  LLVM: libLLVM-13.0.1 (ORCJIT, znver3)  
  Threads: 1 on 128 virtual cores  
  

## Case 1: Low capacity to encourage contention

This benchmark evaluates the performance of **data operations (put and take)**, without task switching.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 50000 | 565.45 | 215.68 | 2.622x |
| 32 | 32 | 4 | 50000 | 346.56 | 41.93 | 8.264x |
| 16 | 16 | 4 | 50000 | 209.27 | 32.08 | 6.524x |
| 8 | 8 | 1 | 50000 | 356.0 | 29.86 | 11.924x |
| 4 | 4 | 1 | 50000 | 164.81 | 18.81 | 8.762x |
| 2 | 2 | 1 | 50000 | 164.3 | 14.25 | 11.527x |
| 1 | 2 | 1 | 50000 | 58.16 | 50.9 | 1.143x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 50000 | 45.84 | 16.99 | 2.698x |
| 32 | 32 | 256 | 50000 | 30.72 | 19.81 | 1.551x |
| 16 | 16 | 256 | 50000 | 25.47 | 17.33 | 1.469x |
| 8 | 8 | 256 | 50000 | 27.76 | 20.37 | 1.363x |
| 4 | 4 | 256 | 50000 | 26.18 | 23.49 | 1.115x |
| 2 | 2 | 256 | 50000 | 16.54 | 12.52 | 1.321x |
| 1 | 2 | 256 | 50000 | 10.8 | 7.58 | 1.426x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 50000 | 26.31 | 18.99 | 1.386x |
| 32 | 256 | 256 | 50000 | 30.77 | 17.71 | 1.737x |
| 32 | 128 | 256 | 50000 | 30.35 | 15.73 | 1.93x |
| 32 | 64 | 256 | 50000 | 33.36 | 14.71 | 2.267x |
| 32 | 32 | 256 | 50000 | 31.75 | 13.77 | 2.306x |
| 32 | 16 | 256 | 50000 | 24.62 | 16.77 | 1.468x |
| 32 | 8 | 256 | 50000 | 24.58 | 16.54 | 1.486x |
