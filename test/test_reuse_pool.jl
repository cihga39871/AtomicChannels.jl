@testset "ReusePool" begin
	@testset "constructors and assertions" begin
		pool = ReusePool(() -> [1], 2)
		@test pool isa ReusePool{Vector{Int64}}
		@test pool.chnl.capacity == 2
		@test pool.chnl.n_filled[] == 1

		typed_pool = ReusePool{Vector{Int}}(() -> [2], 3)
		@test typed_pool isa ReusePool{Vector{Int}}
		@test typed_pool.chnl.capacity == 3

		@test_throws AssertionError ReusePool(() -> [1], 0)
		@test_throws AssertionError ReusePool(() -> nothing, 1)
		@test_throws AssertionError ReusePool{Int}(() -> "x", 1)
	end

	@testset "take! and put! apply reset" begin
		reset!(x) = (empty!(x); push!(x, 0); x)
		pool = ReusePool(() -> [10], 2, reset!)

		v = take!(pool)
		@test v == [10]
		push!(v, 99)
		put!(pool, v)

		v2 = take!(pool)
		@test v2 == [0]
	end

	@testset "acquire! and release!" begin
		reset!(x) = (x[1] = 0; x)
		pool = ReusePool(() -> [1], 1, reset!)

		first_item = acquire!(pool)
		@test first_item == [1]

		# Pool is now empty, so this should create a new object.
		created_item = acquire!(pool)
		@test created_item == [1]
		@test created_item !== first_item

		@test release!(pool, first_item)
		@test first_item == [0]

		# Pool is full; failed release should not apply reset.
		other = [9]
		@test !release!(pool, other)
		@test other == [9]
	end

	@testset "fill! fills to capacity" begin
		counter = Ref(0)
		create_item() = begin
			counter[] += 1
			[counter[]]
		end

		pool = ReusePool(create_item, 3)
		@test counter[] == 1
		@test pool.chnl.n_filled[] == 1

		returned_pool = fill!(pool)
		@test returned_pool === pool
		@test pool.chnl.n_filled[] == 3
		@test counter[] == 3

		@test take!(pool) == [1]
		@test take!(pool) == [2]
		@test take!(pool) == [3]
	end

	@testset "ReusePool pretty print" begin
		pool = ReusePool(() -> Vector{Int}(undef, 2), 3)
		put!(pool, [1, 2])

		s_short = sprint(show, pool)
		s_plain = sprint(show, MIME"text/plain"(), pool)

		@test occursin("ReusePool{Vector{Int64}} with 2/3 items", s_short)
		@test occursin("ReusePool{Vector{Int64}} with 2/3 items", s_plain)
	end
end
