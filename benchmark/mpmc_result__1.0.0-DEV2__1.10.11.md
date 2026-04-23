
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-04-23 14:07:37  
AtomicChannels.jl Version 1.0.0-DEV2  
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

This benchmark evaluates the performance of **data operations (put and take)**, without task switching.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 50000 | 1183.15 | 52.54 | 22.519x |
| 32 | 32 | 4 | 50000 | 380.39 | 40.76 | 9.332x |
| 16 | 16 | 4 | 50000 | 171.5 | 32.23 | 5.321x |
| 8 | 8 | 1 | 50000 | 128.08 | 25.29 | 5.064x |
| 4 | 4 | 1 | 50000 | 110.71 | 19.02 | 5.822x |
| 2 | 2 | 1 | 50000 | 173.33 | 14.22 | 12.19x |
| 1 | 2 | 1 | 50000 | 57.16 | 50.5 | 1.132x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 50000 | 74.44 | 15.73 | 4.733x |
| 32 | 32 | 256 | 50000 | 48.2 | 17.15 | 2.81x |
| 16 | 16 | 256 | 50000 | 41.11 | 15.73 | 2.613x |
| 8 | 8 | 256 | 50000 | 30.77 | 15.55 | 1.979x |
| 4 | 4 | 256 | 50000 | 21.73 | 10.86 | 2.001x |
| 2 | 2 | 256 | 50000 | 15.78 | 11.58 | 1.363x |
| 1 | 2 | 256 | 50000 | 10.89 | 7.75 | 1.405x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 50000 | 29.38 | 16.65 | 1.765x |
| 32 | 256 | 256 | 50000 | 28.95 | 16.08 | 1.8x |
| 32 | 128 | 256 | 50000 | 31.68 | 16.6 | 1.909x |
| 32 | 64 | 256 | 50000 | 44.86 | 15.57 | 2.881x |
| 32 | 32 | 256 | 50000 | 44.22 | 14.75 | 2.997x |
| 32 | 16 | 256 | 50000 | 47.57 | 18.65 | 2.551x |
| 32 | 8 | 256 | 50000 | 35.01 | 24.13 | 1.451x |
