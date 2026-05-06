
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-05-06 09:39:40  
AtomicChannels.jl Version 1.0.2  
Julia Version 1.10.11  
Commit a2b11907d7b (2026-03-09 14:59 UTC)  
Build Info:  
  Official https://julialang.org/ release  
Platform Info:  
  OS: Linux (x86_64-linux-gnu)  
  CPU: 128 × AMD Ryzen Threadripper PRO 7985WX 64-Cores  
  WORD_SIZE: 64  
  LIBM: libopenlibm  
  LLVM: libLLVM-15.0.7 (ORCJIT, znver3)  
  

## Case 1: Low capacity to encourage contention

This benchmark evaluates the performance of **data operations (put and take)**, without task switching (when threads>1).

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 100000 | 1507.82 | 115.07 | 13.103x |
| 32 | 32 | 4 | 100000 | 596.96 | 68.93 | 8.66x |
| 16 | 16 | 4 | 100000 | 358.29 | 52.09 | 6.878x |
| 8 | 8 | 1 | 100000 | 439.96 | 63.43 | 6.936x |
| 4 | 4 | 1 | 100000 | 219.42 | 28.88 | 7.599x |
| 2 | 2 | 1 | 100000 | 127.09 | 34.48 | 3.686x |
| 1 | 2 | 1 | 100000 | 121.91 | 110.63 | 1.102x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 100000 | 125.2 | 25.68 | 4.876x |
| 32 | 32 | 256 | 100000 | 80.03 | 22.77 | 3.514x |
| 16 | 16 | 256 | 100000 | 69.7 | 19.54 | 3.567x |
| 8 | 8 | 256 | 100000 | 53.67 | 29.91 | 1.795x |
| 4 | 4 | 256 | 100000 | 42.51 | 23.45 | 1.813x |
| 2 | 2 | 256 | 100000 | 21.88 | 18.89 | 1.158x |
| 1 | 2 | 256 | 100000 | 16.26 | 9.9 | 1.643x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 100000 | 45.24 | 29.18 | 1.55x |
| 32 | 256 | 256 | 100000 | 51.56 | 22.54 | 2.288x |
| 32 | 128 | 256 | 100000 | 50.39 | 25.9 | 1.946x |
| 32 | 64 | 256 | 100000 | 55.77 | 22.35 | 2.495x |
| 32 | 32 | 256 | 100000 | 88.91 | 20.19 | 4.403x |
| 32 | 16 | 256 | 100000 | 94.97 | 28.2 | 3.367x |
| 32 | 8 | 256 | 100000 | 45.03 | 28.13 | 1.601x |
