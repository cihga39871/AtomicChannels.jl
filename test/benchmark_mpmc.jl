using Markdown

function run_mpmc_benchmark(; n_items::Int, capacity::Int, n_producers::Int, n_consumers::Int, make_queue, put_func, take_func)
    expected_sum = n_items * (n_items + 1) ÷ 2
    consumed_sum = Atomic{Int}(0)
    queue = make_queue(capacity)

    per_producer = n_items ÷ n_producers
    producer_rem = n_items % n_producers

    per_consumer = n_items ÷ n_consumers
    consumer_rem = n_items % n_consumers

    # precompile
    put_func(queue, 0)
    take_func(queue)

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

function benchmark_mpmc_pool_vs_channel(n_items::Int, capacity::Int, n_producers::Int, n_consumers::Int; run_test::Bool = true, markdown_output::Bool = true, raw_markdown::Bool = false, raw_mardown_header::Bool = true)
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
    #=
    pool_elapsed, pool_sum, pool_expected = run_mpmc_benchmark(
        n_items = 50000,
        capacity = 4,
        n_producers = 16,
        n_consumers = 16,
        make_queue = cap -> AtomicChannel{Int}(cap),
        put_func = put!,
        take_func = take!,
    )=#

    if run_test
        @test channel_sum == channel_expected
        @test pool_sum == pool_expected
    end
    
    channel_ms = channel_elapsed / 1_000_000
    pool_ms = pool_elapsed / 1_000_000
    ratio = channel_elapsed / max(pool_elapsed, 1)
    workers = n_producers + n_consumers

    md_header = """
| threads | workers | capacity | items | Channel/ms | AtomicChannel/ms | speedup |
|---:|---:|---:|---:|---:|---:|---:|
"""
    md_row = "| $(nthreads()) | $workers | $capacity | $n_items | $(round(channel_ms; digits=2)) | $(round(pool_ms; digits=2)) | $(round(ratio; digits=3))x |\n"

    if markdown_output
        benchmark_md = Markdown.parse("$md_header$md_row")
        show(stdout, MIME"text/plain"(), benchmark_md)
        print(stdout, '\n')
    end
    if raw_markdown
        if raw_mardown_header
            return md_header * md_row
        else
            return md_row
        end
    end
end

function benchmark_stdout_markdown(capacity::Int; worker_ratio::Real = 2)
    n_workers = max(1, nthreads() / 2 * worker_ratio)
    n_workers = floor(Int, n_workers)

    md1 = benchmark_mpmc_pool_vs_channel(50_000, capacity, n_workers, n_workers; markdown_output = false, raw_markdown = true)    

    println(stdout, md1)
end