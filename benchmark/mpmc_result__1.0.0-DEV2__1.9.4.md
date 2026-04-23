
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-04-23 14:07:24  
AtomicChannels.jl Version 1.0.0-DEV2  
Julia Version 1.9.4  
Commit 8e5136fa297 (2023-11-14 08:46 UTC)  
Build Info:  
  Official https://julialang.org/ release  
Platform Info:  
  OS: Linux (x86_64-linux-gnu)  
  CPU: 128 × AMD Ryzen Threadripper PRO 7985WX 64-Cores  
  WORD_SIZE: 64  
  LIBM: libopenlibm  
  LLVM: libLLVM-14.0.6 (ORCJIT, znver3)  
  Threads: 1 on 128 virtual cores  
  

## Case 1: Low capacity to encourage contention

This benchmark evaluates the performance of **data operations (put and take)**, without task switching.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 50000 | 571.93 | 57.59 | 9.931x |
| 32 | 32 | 4 | 50000 | 329.54 | 43.46 | 7.583x |
| 16 | 16 | 4 | 50000 | 182.87 | 27.45 | 6.661x |
| 8 | 8 | 1 | 50000 | 269.69 | 53.43 | 5.047x |
| 4 | 4 | 1 | 50000 | 129.36 | 24.97 | 5.181x |
| 2 | 2 | 1 | 50000 | 100.03 | 18.45 | 5.421x |
| 1 | 2 | 1 | 50000 | 62.36 | 52.21 | 1.194x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 50000 | 74.04 | 16.53 | 4.478x |
| 32 | 32 | 256 | 50000 | 45.7 | 12.85 | 3.556x |
| 16 | 16 | 256 | 50000 | 47.2 | 15.46 | 3.054x |
| 8 | 8 | 256 | 50000 | 31.48 | 16.1 | 1.955x |
| 4 | 4 | 256 | 50000 | 31.45 | 21.97 | 1.431x |
| 2 | 2 | 256 | 50000 | 16.08 | 12.12 | 1.327x |
| 1 | 2 | 256 | 50000 | 12.05 | 7.68 | 1.57x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 50000 | 31.16 | 20.57 | 1.515x |
| 32 | 256 | 256 | 50000 | 31.32 | 16.94 | 1.849x |
| 32 | 128 | 256 | 50000 | 36.64 | 14.37 | 2.549x |
| 32 | 64 | 256 | 50000 | 39.21 | 15.67 | 2.502x |
| 32 | 32 | 256 | 50000 | 47.91 | 13.31 | 3.601x |
| 32 | 16 | 256 | 50000 | 52.24 | 22.47 | 2.325x |
| 32 | 8 | 256 | 50000 | 27.78 | 16.28 | 1.706x |
