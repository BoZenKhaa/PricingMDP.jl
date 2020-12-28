using RandomNumbers.Xorshifts

@testset "PMDPg.jl" begin

    # initialize 
    pp = simple_pp()
    rng = Xorshift128Plus(1)
    mg = PMDPs.PMDPg(pp)

    @test PMDPs.empty_product(mg) == PMDPs.Product(falses(mg.nᵣ), PMDPs.selling_period_end(pp))    

    # Test methods
    @test typeof(PMDPs.sample_request(mg, 1, rng)) == PMDPs.Product{2}
   
    s = PMDPs.State(pp.c₀, 1, 1)
    @test typeof(PMDPs.sample_customer_budget(mg, s, rng)) == Float64
    @test minimum(pp.B[1])<=PMDPs.sample_customer_budget(mg, s, rng)<=maximum(pp.B[1])

    sₑ = PMDPs.State(pp.c₀, 1, mg.empty_product_id)
    @test PMDPs.sample_customer_budget(mg, sₑ, rng)==PMDPs.EMPTY_PRODUCT_USER_BUDGET
    

end