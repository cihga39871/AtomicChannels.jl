
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-05-06 09:40:14  
AtomicChannels.jl Version 1.0.2  
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

This benchmark evaluates the performance of **data operations (put and take)**, without task switching (when threads>1).

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 100000 | 1144.58 | 181.37 | 6.311x |
| 32 | 32 | 4 | 100000 | 726.77 | 60.09 | 12.095x |
| 16 | 16 | 4 | 100000 | 413.49 | 55.5 | 7.45x |
| 8 | 8 | 1 | 100000 | 962.09 | 61.0 | 15.771x |
| 4 | 4 | 1 | 100000 | 279.89 | 34.16 | 8.193x |
| 2 | 2 | 1 | 100000 | 298.52 | 25.9 | 11.525x |
| 1 | 2 | 1 | 100000 | 108.66 | 100.73 | 1.079x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 100000 | 51.35 | 25.76 | 1.994x |
| 32 | 32 | 256 | 100000 | 41.21 | 24.57 | 1.677x |
| 16 | 16 | 256 | 100000 | 50.51 | 24.99 | 2.021x |
| 8 | 8 | 256 | 100000 | 40.53 | 32.69 | 1.24x |
| 4 | 4 | 256 | 100000 | 32.33 | 19.02 | 1.7x |
| 2 | 2 | 256 | 100000 | 25.01 | 18.49 | 1.353x |
| 1 | 2 | 256 | 100000 | 15.17 | 8.23 | 1.844x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 100000 | 46.29 | 22.25 | 2.081x |
| 32 | 256 | 256 | 100000 | 43.9 | 25.69 | 1.709x |
| 32 | 128 | 256 | 100000 | 48.61 | 23.78 | 2.044x |
| 32 | 64 | 256 | 100000 | 49.34 | 24.2 | 2.039x |
| 32 | 32 | 256 | 100000 | 43.71 | 21.77 | 2.008x |
| 32 | 16 | 256 | 100000 | 34.84 | 24.72 | 1.41x |
| 32 | 8 | 256 | 100000 | 39.46 | 27.55 | 1.432x |
