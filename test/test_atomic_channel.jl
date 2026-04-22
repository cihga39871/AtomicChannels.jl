
function run_mpmc_benchmark(; n_items::Int, capacity::Int, n_producers::Int, n_consumers::Int, make_queue, put_func, take_func)
    expected_sum = n_items * (n_items + 1) ÷ 2
    consumed_sum = Atomic{Int}(0)
    queue = make_queue(capacity)

    per_producer = n_items ÷ n_producers
    producer_rem = n_items % n_producers

    per_consumer = n_items ÷ n_consumers
    consumer_rem = n_items % n_consumers

    t0 = time_ns()
    @sync begin
        start = 1
        for i in 1:n_producers
            count = per_producer + (i <= producer_rem ? 1 : 0)
            first_item = start
            last_item = start + count - 1
            start += count

            Threads.@spawn begin
                for x in first_item:last_item
                    put_func(queue, x)
                end
            end
        end

        for i in 1:n_consumers
            count = per_consumer + (i <= consumer_rem ? 1 : 0)
            Threads.@spawn begin
                local_sum = 0
                for _ in 1:count
                    local_sum += take_func(queue)
                end
                atomic_add!(consumed_sum, local_sum)
            end
        end
    end
    elapsed_ns = time_ns() - t0

    return elapsed_ns, consumed_sum[], expected_sum
end

function benchmark_mpmc_pool_vs_channel(n_items::Int, capacity::Int, n_producers::Int, n_consumers::Int)
    channel_elapsed, channel_sum, channel_expected = run_mpmc_benchmark(
        n_items = n_items,
        capacity = capacity,
        n_producers = n_producers,
        n_consumers = n_consumers,
        make_queue = cap -> Channel{Int}(cap),
        put_func = put!,
        take_func = take!,
    )

    pool_elapsed, pool_sum, pool_expected = run_mpmc_benchmark(
        n_items = n_items,
        capacity = capacity,
        n_producers = n_producers,
        n_consumers = n_consumers,
        make_queue = cap -> AtomicChannel{Int}(cap),
        put_func = put!,
        take_func = take!,
    )

    @test channel_sum == channel_expected
    @test pool_sum == pool_expected

    channel_ms = channel_elapsed / 1_000_000
    pool_ms = pool_elapsed / 1_000_000
    ratio = channel_elapsed / max(pool_elapsed, 1)

    println("\n[benchmark] items=$n_items capacity=$capacity threads=$(nthreads()) workers=$n_producers")
    println("[benchmark]     Channel              elapsed ms  $(round(channel_ms; digits=2))")
    println("[benchmark]     AtomicChannel        elapsed ms  $(round(pool_ms; digits=2))")
    println("[benchmark]     speedup (Channel/AtomicChannel)  $(round(ratio; digits=3))x ")
end

@testset "AtomicChannel" begin
    @testset "AtomicChannel basic FIFO" begin
        chnl = AtomicChannel{Int}(3)
        @test isempty(chnl)

        put!(chnl, 1)
        put!(chnl, 2)
        put!(chnl, 3)

        @test isready(chnl)
        @test take!(chnl) == 1
        @test take!(chnl) == 2
        @test take!(chnl) == 3
        @test isempty(chnl)
    end

    @testset "AtomicChannel blocks when empty/full" begin
        chnl = AtomicChannel{Int}(1)

        t_take = @async take!(chnl)
        yield()
        @test !istaskdone(t_take)
        put!(chnl, 11)
        @test fetch(t_take) == 11

        put!(chnl, 21)
        t_put = @async put!(chnl, 22)
        yield()
        @test !istaskdone(t_put)
        @test take!(chnl) == 21
        fetch(t_put)
        @test take!(chnl) == 22
    end

    @testset "AtomicChannel concurrent producers consumers" begin
        chnl = AtomicChannel{Int}(64)
        n_items = 2000
        expected_sum = n_items * (n_items + 1) ÷ 2
        consumed_sum = Atomic{Int}(0)

        producer = Threads.@spawn begin
            for i in 1:n_items
                put!(chnl, i)
            end
        end

        n_consumers = max(2, nthreads())
        per_consumer = n_items ÷ n_consumers
        rem_items = n_items % n_consumers
        consumers = Task[]

        for i in 1:n_consumers
            n_take = per_consumer + (i <= rem_items ? 1 : 0)
            push!(consumers, Threads.@spawn begin
                local_sum = 0
                for _ in 1:n_take
                    local_sum += take!(chnl)
                end
                atomic_add!(consumed_sum, local_sum)
            end)
        end

        fetch(producer)
        foreach(fetch, consumers)
        @test consumed_sum[] == expected_sum
        @test isempty(chnl)
    end

    @testset "AtomicChannel non-blocking API" begin
        chnl = AtomicChannel{Int}(1)
        @test trytake!(chnl) === nothing

        @test tryput!(chnl, 7)
        @test !tryput!(chnl, 8)
        @test trytake!(chnl) == 7
        @test trytake!(chnl) === nothing
    end

    @testset "AtomicChannel pretty print" begin
        chnl = AtomicChannel{Int}(3)
        put!(chnl, 1)
        put!(chnl, 2)

        s_short = sprint(show, chnl)
        s_plain = sprint(show, MIME"text/plain"(), chnl)

        @test occursin("AtomicChannel{Int64}(2/3)", s_short)
        @test occursin("AtomicChannel{Int64} with 2/3 items", s_plain)
        @test occursin("slots", s_plain)
    end

    @testset "AtomicChannel ring-index wrap-around" begin
        chnl = AtomicChannel{Int}(6)
        chnl.head[] = 5
        chnl.tail[] = 5

        put!(chnl, 11)
        put!(chnl, 12)
        put!(chnl, 13)
        put!(chnl, 14)
        @test chnl.cells[1].state[] == 1
        @test chnl.cells[2].state[] == 1
        @test chnl.cells[3].state[] == 1
        @test chnl.cells[4].state[] == 0
        @test chnl.cells[5].state[] == 0
        @test chnl.cells[6].state[] == 1

        @test take!(chnl) == 11
        @test take!(chnl) == 12
        @test take!(chnl) == 13
        @test take!(chnl) == 14
        @test isempty(chnl)
    end

    @testset "AtomicChannel compatibility and utility API" begin
        chnl = AtomicChannel{Int}(2)

        @test length(chnl) == 2
        @test eltype(AtomicChannel{Int}) == Int
        @test eltype(typeof(AtomicChannel(2))) == Any
        @test isopen(chnl)
        @test Base.isbuffered(chnl)
        @test Base.check_channel_state(chnl) === nothing
        @test close(chnl) === nothing
        @test close(chnl, ErrorException("x")) === nothing
        @test Base.n_avail(chnl) == 0
        @test lock(chnl) === nothing
        @test unlock(chnl) === nothing
        @test lock(() -> 123, chnl) == 123

        # wait should block until an item is available, but not consume that item.
        t_wait = @async begin
            wait(chnl)
            :ok
        end
        yield()
        @test !istaskdone(t_wait)
        put!(chnl, 7)
        @test fetch(t_wait) == :ok
        @test Base.n_avail(chnl) == 1
        @test take!(chnl) == 7

        put!(chnl, 11)
        @test fetch(chnl) == 11
        @test Base.n_avail(chnl) == 1
        @test take!(chnl) == 11

        # iterate consumes one item and returns `nothing` as state.
        put!(chnl, 21)
        put!(chnl, 22)
        iter = iterate(chnl)
        @test iter !== nothing
        value, state = iter
        @test value == 21
        @test state === nothing
        @test Base.n_avail(chnl) == 1
        @test take!(chnl) == 22

        put!(chnl, 31)
        put!(chnl, 32)
        empty!(chnl)
        @test isempty(chnl)
        @test Base.n_avail(chnl) == 0

        # iterate related
        put!(chnl, 41)
        put!(chnl, 42)
        values = collect(chnl)
        @test values == [41, 42]
        @test isempty(chnl)

        # iterate with empty items
        chnl2 = AtomicChannel{Any}(2)
        put!(chnl2, nothing)
        put!(chnl2, "abc")
        values2 = collect(chnl2)
        @test values2 == [nothing, "abc"]
        @test isempty(chnl2)
    end

    @testset "AtomicChannel tryput! with reset function" begin
        chnl = AtomicChannel{Vector{Int}}(1)

        v = [1]
        @test tryput!(x -> (x[1] = 99), chnl, v)
        @test take!(chnl)[1] == 99

        put!(chnl, [7])
        called = Ref(false)
        v2 = [2]
        ok = tryput!(x -> begin
            called[] = true
            x[1] = 5
        end, chnl, v2)
        @test !ok
        @test !called[]
        @test take!(chnl)[1] == 7
        @test v2[1] == 2
    end

    @testset "Channel vs AtomicChannel benchmark (multithreaded)" begin
        n_workers = max(2, nthreads() )

        benchmark_mpmc_pool_vs_channel(100_000, 256, n_workers, n_workers)
        
        benchmark_mpmc_pool_vs_channel(10_000, 4, n_workers, n_workers)
    end
end
