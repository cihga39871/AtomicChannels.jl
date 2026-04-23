
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-04-23 14:07:51  
AtomicChannels.jl Version 1.0.0-DEV2  
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

This benchmark evaluates the performance of **data operations (put and take)**, without task switching.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 50000 | 657.77 | 53.12 | 12.383x |
| 32 | 32 | 4 | 50000 | 465.59 | 38.92 | 11.964x |
| 16 | 16 | 4 | 50000 | 254.11 | 29.5 | 8.613x |
| 8 | 8 | 1 | 50000 | 174.36 | 30.87 | 5.648x |
| 4 | 4 | 1 | 50000 | 188.14 | 45.68 | 4.118x |
| 2 | 2 | 1 | 50000 | 103.91 | 18.93 | 5.491x |
| 1 | 2 | 1 | 50000 | 61.44 | 57.32 | 1.072x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 50000 | 79.92 | 22.64 | 3.53x |
| 32 | 32 | 256 | 50000 | 48.33 | 20.15 | 2.399x |
| 16 | 16 | 256 | 50000 | 36.87 | 15.9 | 2.319x |
| 8 | 8 | 256 | 50000 | 34.1 | 20.85 | 1.635x |
| 4 | 4 | 256 | 50000 | 34.78 | 15.79 | 2.203x |
| 2 | 2 | 256 | 50000 | 18.23 | 14.23 | 1.281x |
| 1 | 2 | 256 | 50000 | 12.18 | 8.94 | 1.362x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 50000 | 33.1 | 19.08 | 1.734x |
| 32 | 256 | 256 | 50000 | 30.18 | 16.66 | 1.811x |
| 32 | 128 | 256 | 50000 | 31.28 | 17.08 | 1.831x |
| 32 | 64 | 256 | 50000 | 33.75 | 13.89 | 2.43x |
| 32 | 32 | 256 | 50000 | 46.78 | 19.5 | 2.399x |
| 32 | 16 | 256 | 50000 | 52.53 | 22.91 | 2.293x |
| 32 | 8 | 256 | 50000 | 34.22 | 15.36 | 2.228x |
