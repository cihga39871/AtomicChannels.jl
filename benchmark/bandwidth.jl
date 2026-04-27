
using AtomicChannels
using Base.Threads

function benchmark_bandwidth(capacity::Int, duration::Real, num_producers::Int, num_consumers::Int)
    @info "Benchmarking bandwidth with capacity=$capacity, duration=$duration, num_producers=$num_producers, num_consumers=$num_consumers"
    ch = AtomicChannel{Int}(capacity)
    
    # Fill the channel with data.
    producers = Task[]
    while_loop = true
    for _ in 1:num_producers
        t = Threads.@spawn begin
            while while_loop
                put!(ch, 1)
            end
        end
        push!(producers, t)
    end

    consumers = Task[]
    for _ in 1:num_consumers
        t = Threads.@spawn begin
            while while_loop
                take!(ch)
            end
        end
        push!(consumers, t)
    end
    
    sleep(duration) # Let the producers and consumers run for a bit.
    while_loop = false
    
    show(stdout, "text/plain", ch)
    println()
    println()

    ch
end

for _ in 1:5
    benchmark_bandwidth(32, 1, 2, 2)
end