
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-05-06 09:39:57  
AtomicChannels.jl Version 1.0.2  
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

This benchmark evaluates the performance of **data operations (put and take)**, without task switching (when threads>1).

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 100000 | 1278.21 | 72.71 | 17.579x |
| 32 | 32 | 4 | 100000 | 650.13 | 68.32 | 9.516x |
| 16 | 16 | 4 | 100000 | 444.22 | 51.13 | 8.688x |
| 8 | 8 | 1 | 100000 | 546.32 | 72.87 | 7.497x |
| 4 | 4 | 1 | 100000 | 276.44 | 32.45 | 8.519x |
| 2 | 2 | 1 | 100000 | 179.24 | 26.53 | 6.757x |
| 1 | 2 | 1 | 100000 | 119.86 | 102.21 | 1.173x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 100000 | 153.34 | 24.91 | 6.155x |
| 32 | 32 | 256 | 100000 | 66.11 | 22.29 | 2.966x |
| 16 | 16 | 256 | 100000 | 61.05 | 26.56 | 2.298x |
| 8 | 8 | 256 | 100000 | 55.68 | 29.9 | 1.862x |
| 4 | 4 | 256 | 100000 | 40.13 | 19.06 | 2.105x |
| 2 | 2 | 256 | 100000 | 27.4 | 18.73 | 1.463x |
| 1 | 2 | 256 | 100000 | 15.4 | 8.87 | 1.736x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 100000 | 47.89 | 26.07 | 1.837x |
| 32 | 256 | 256 | 100000 | 55.64 | 23.51 | 2.367x |
| 32 | 128 | 256 | 100000 | 48.11 | 18.49 | 2.602x |
| 32 | 64 | 256 | 100000 | 60.02 | 21.89 | 2.742x |
| 32 | 32 | 256 | 100000 | 66.77 | 24.89 | 2.683x |
| 32 | 16 | 256 | 100000 | 79.34 | 24.49 | 3.24x |
| 32 | 8 | 256 | 100000 | 47.7 | 27.82 | 1.714x |
