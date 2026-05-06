
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-05-06 09:38:57  
AtomicChannels.jl Version 1.0.2  
Julia Version 1.12.6  
Commit 15346901f00 (2026-04-09 19:20 UTC)  
Build Info:  
  Official https://julialang.org release  
Platform Info:  
  OS: Linux (x86_64-linux-gnu)  
  CPU: 128 × AMD Ryzen Threadripper PRO 7985WX 64-Cores  
  WORD_SIZE: 64  
  LLVM: libLLVM-18.1.7 (ORCJIT, znver4)  
  GC: Built with stock GC  
  

## Case 1: Low capacity to encourage contention

This benchmark evaluates the performance of **data operations (put and take)**, without task switching (when threads>1).

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 100000 | 2779.6 | 82.24 | 33.8x |
| 32 | 32 | 4 | 100000 | 1441.26 | 71.42 | 20.18x |
| 16 | 16 | 4 | 100000 | 772.32 | 56.61 | 13.643x |
| 8 | 8 | 1 | 100000 | 465.8 | 39.79 | 11.707x |
| 4 | 4 | 1 | 100000 | 190.83 | 25.54 | 7.47x |
| 2 | 2 | 1 | 100000 | 121.67 | 24.58 | 4.95x |
| 1 | 2 | 1 | 100000 | 121.58 | 115.59 | 1.052x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 100000 | 69.6 | 23.02 | 3.023x |
| 32 | 32 | 256 | 100000 | 39.93 | 24.44 | 1.633x |
| 16 | 16 | 256 | 100000 | 37.29 | 24.84 | 1.501x |
| 8 | 8 | 256 | 100000 | 26.3 | 30.24 | 0.87x |
| 4 | 4 | 256 | 100000 | 23.38 | 19.17 | 1.22x |
| 2 | 2 | 256 | 100000 | 17.72 | 14.92 | 1.188x |
| 1 | 2 | 256 | 100000 | 13.99 | 10.88 | 1.286x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 100000 | 620.24 | 26.56 | 23.351x |
| 32 | 256 | 256 | 100000 | 732.27 | 26.49 | 27.638x |
| 32 | 128 | 256 | 100000 | 696.89 | 27.65 | 25.201x |
| 32 | 64 | 256 | 100000 | 678.93 | 22.85 | 29.715x |
| 32 | 32 | 256 | 100000 | 40.13 | 18.56 | 2.162x |
| 32 | 16 | 256 | 100000 | 31.29 | 22.38 | 1.398x |
| 32 | 8 | 256 | 100000 | 26.36 | 18.23 | 1.446x |
