using RandomNumbers.Xorshifts

@testset "PMDPg.jl" begin

    # initialize 
    pp = simple_pp()
    rng = Xorshift128Plus(1)
    mg = PMDPs.PMDPg(pp)

    @test PMDPs.empty_product(mg) ==
          PMDPs.Product(falses(PMDPs.n_resources(mg)), PMDPs.selling_period_end(mg))

    # Test methods
    @test 1 <= PMDPs.sample_request(mg, 1, rng) <= PMDPs.n_products(mg) + 1

    s = PMDPs.State(pp.c₀, 1, 1)
    @test typeof(PMDPs.sample_customer_budget(mg, s, rng)) == Float64
    @test minimum(pp.B[1]) <= PMDPs.sample_customer_budget(mg, s, rng) <= maximum(pp.B[1])

    sₑ = PMDPs.State(pp.c₀, 1, mg.empty_product_id)
    @test PMDPs.sample_customer_budget(mg, sₑ, rng) == PMDPs.EMPTY_PRODUCT_USER_BUDGET


    s₀ = PMDPs.State(pp.c₀, 1, 1)
    a = 10.0
    rng = Xorshift128Plus(1)
    sp, r, info = POMDPs.gen(mg, s, a, rng)
    @test sp.t == 2
    @test r >= 0.0
    @test info.b >= 0.0

end
