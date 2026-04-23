
# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl

Date: 2026-04-23 14:14:30  
AtomicChannels.jl Version 1.0.0-DEV2  
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

This benchmark evaluates the performance of **data operations (put and take)**, without task switching.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 4 | 50000 | 1349.91 | 58.28 | 23.161x |
| 32 | 32 | 4 | 50000 | 783.57 | 42.76 | 18.326x |
| 16 | 16 | 4 | 50000 | 438.03 | 29.93 | 14.638x |
| 8 | 8 | 1 | 50000 | 377.94 | 42.95 | 8.799x |
| 4 | 4 | 1 | 50000 | 133.53 | 18.69 | 7.145x |
| 2 | 2 | 1 | 50000 | 68.55 | 14.69 | 4.666x |
| 1 | 2 | 1 | 50000 | 64.59 | 60.63 | 1.065x |

## Case 2: Higher capacity with minimal contention

This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. 

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 256 | 50000 | 30.65 | 14.01 | 2.188x |
| 32 | 32 | 256 | 50000 | 25.36 | 15.42 | 1.644x |
| 16 | 16 | 256 | 50000 | 21.78 | 18.27 | 1.192x |
| 8 | 8 | 256 | 50000 | 15.35 | 15.29 | 1.004x |
| 4 | 4 | 256 | 50000 | 20.01 | 12.1 | 1.653x |
| 2 | 2 | 256 | 50000 | 15.2 | 10.06 | 1.512x |
| 1 | 2 | 256 | 50000 | 11.73 | 10.49 | 1.118x |

## Case 3: Varying worker (task) counts to mimic different levels of concurrency

This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.

| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
| 32 | 512 | 256 | 50000 | 260.79 | 23.59 | 11.057x |
| 32 | 256 | 256 | 50000 | 296.34 | 24.48 | 12.106x |
| 32 | 128 | 256 | 50000 | 363.13 | 22.42 | 16.196x |
| 32 | 64 | 256 | 50000 | 316.99 | 20.97 | 15.114x |
| 32 | 32 | 256 | 50000 | 24.08 | 15.28 | 1.576x |
| 32 | 16 | 256 | 50000 | 18.35 | 20.34 | 0.902x |
| 32 | 8 | 256 | 50000 | 14.65 | 12.78 | 1.147x |
