
#=
To run this benchmark, execute the following command in the terminal:

```bash
julia +1.8 --project benchmark/mpmc.jl
julia +1.9 --project benchmark/mpmc.jl
julia +1.10 --project benchmark/mpmc.jl
julia +1.11 --project benchmark/mpmc.jl
julia +1.12 --project benchmark/mpmc.jl
```
=#

using AtomicChannels
using Test
using Markdown
using Dates
using InteractiveUtils
using Pkg
Pkg.update()

proj = dirname(Base.active_project())

if !isdefined(Main, :pkgversion)  # julia 1.9+ has a built-in `pkgversion` function, so we only define it if it's not already defined.
    function pkgversion(pkg::Module)
        # only works for the current project
        proj_toml = Pkg.TOML.parsefile(joinpath(proj, "Project.toml"))
        return proj_toml["version"]
    end
end

function run_benchmark_and_capture(stdout::IO, threads::Int, capacity::Int, worker_ratio::Real = 2)
    jl_code = """using AtomicChannels; using Test; using Base.Threads; include(joinpath("test", "benchmark_mpmc.jl")); benchmark_stdout_markdown($capacity; worker_ratio = $worker_ratio)"""
    cmd = `$(Base.julia_cmd()) -t $threads --project=$proj -e $jl_code`
    @info "Running benchmark with $threads threads, capacity $capacity, worker_ratio $worker_ratio..."

    tmp_io = IOBuffer()
    run(pipeline(cmd, stdout=tmp_io))
    print(stdout, String(take!(tmp_io)))  # Print the captured output to the main stdout
    close(tmp_io)  # Close the IOBuffer to flush all data
end

function print_table(f::IO, io::IO)
    lines = split(String(take!(io)), '\n')
    unique!(lines)
    filter!(x -> !isempty(x), lines)

    for line in lines
        println(f, line)
    end
    flush(f)
end

outfile = joinpath(proj, "benchmark", "mpmc_result__$(pkgversion(AtomicChannels))__$(VERSION).md")

open(outfile, "w+") do f
    io = IOBuffer()

    println(f, "\n# Benchmark: Multi-producer multi-consumer (MPMC) performance of AtomicChannels.jl\n")

    println(f, "Date: ", Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS"), "  ")
    println(f, "AtomicChannels.jl Version ", pkgversion(AtomicChannels), "  ")

    versioninfo(io)
    lines = split(String(take!(io)), '\n')
    for line in lines
        if startswith(line, "Threads")
            continue  # Skip because the real thread count is determined by the benchmark command, not the wrapper process.
        end
        println(f, line, "  ")  # Add two spaces for Markdown line break
    end

    println(f, "\n## Case 1: Low capacity to encourage contention\n")
    println(f, "This benchmark evaluates the performance of **data operations (put and take)**, without task switching.\n")
    for threads in [64, 32, 16]
        run_benchmark_and_capture(io, threads, 4, 1)
    end
    for threads in [8, 4, 2, 1]
        run_benchmark_and_capture(io, threads, 1, 1)
    end
    print_table(f, io)

    println(f, "\n## Case 2: Higher capacity with minimal contention\n")
    println(f, "This benchmark mimics a lowest contention scenario where the contention is only from **task switching**, not data operations. \n")
    for threads in [64, 32, 16, 8, 4, 2, 1]
        run_benchmark_and_capture(io, threads, 256, 1)
    end
    print_table(f, io)

    println(f, "\n## Case 3: Varying worker (task) counts to mimic different levels of concurrency\n")
    println(f, "This benchmark mimics varying concurrency levels on both **data operations** and **task switching**.\n")
    for worker_ratio in [16, 8, 4, 2, 1, 0.5, 0.25]
        run_benchmark_and_capture(io, 32, 256, worker_ratio)
    end
    print_table(f, io)

    close(io)
end

@info "Benchmark results appended to $outfile"
