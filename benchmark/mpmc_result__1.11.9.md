
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-05-06 09:39:23  
AtomicChannels.jl Version 1.0.2  
Julia Version 1.11.9  
Commit 53a02c0720c (2026-02-06 00:27 UTC)  
Build Info:  
  Official https://julialang.org/ release  
Platform Info:  
  OS: Linux (x86_64-linux-gnu)  
  CPU: 128 × AMD Ryzen Threadripper PRO 7985WX 64-Cores  
  WORD_SIZE: 64  
  LLVM: libLLVM-16.0.6 (ORCJIT, znver4)  
  

## Case 1: Low capacity to encourage contention

This benchmark evaluates the performance of **data operations (put and take)**, without task switching (when threads>1).

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 100000 | 1398.5 | 143.42 | 9.751x |
| 32 | 32 | 4 | 100000 | 678.46 | 74.36 | 9.124x |
| 16 | 16 | 4 | 100000 | 405.61 | 55.16 | 7.353x |
| 8 | 8 | 1 | 100000 | 384.79 | 55.46 | 6.939x |
| 4 | 4 | 1 | 100000 | 147.87 | 28.6 | 5.169x |
| 2 | 2 | 1 | 100000 | 146.33 | 26.65 | 5.491x |
| 1 | 2 | 1 | 100000 | 116.0 | 104.72 | 1.108x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 100000 | 126.33 | 28.71 | 4.4x |
| 32 | 32 | 256 | 100000 | 88.66 | 24.63 | 3.6x |
| 16 | 16 | 256 | 100000 | 55.28 | 26.61 | 2.078x |
| 8 | 8 | 256 | 100000 | 43.86 | 25.34 | 1.731x |
| 4 | 4 | 256 | 100000 | 36.79 | 18.32 | 2.008x |
| 2 | 2 | 256 | 100000 | 22.19 | 18.1 | 1.226x |
| 1 | 2 | 256 | 100000 | 13.96 | 9.82 | 1.421x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 100000 | 47.16 | 23.39 | 2.017x |
| 32 | 256 | 256 | 100000 | 43.26 | 19.98 | 2.165x |
| 32 | 128 | 256 | 100000 | 45.85 | 23.58 | 1.944x |
| 32 | 64 | 256 | 100000 | 52.13 | 24.88 | 2.095x |
| 32 | 32 | 256 | 100000 | 163.46 | 37.71 | 4.335x |
| 32 | 16 | 256 | 100000 | 70.11 | 23.83 | 2.941x |
| 32 | 8 | 256 | 100000 | 47.96 | 27.51 | 1.743x |
