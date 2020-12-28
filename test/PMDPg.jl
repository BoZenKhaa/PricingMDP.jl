using Random

@testset "PMDPg.jl" begin

    # initialize 
    pp = simple_pp()

    mg = PMDPs.PMDPg(pp)

    @test PMDPs.empty_product(mg) == PMDPs.Product(falses(mg.nᵣ), PMDPs.selling_period_end(pp))    

    # Test methods
    @test typeof(PMDPs.sample_request(mg, 1, MersenneTwister(1))) == PMDPs.Product{2}
   
    
    s = PMDPs.State(pp.c₀, 1, 1)
    @test typeof(PMDPs.sample_customer_budget(mg, s, MersenneTwister(1))) == Float64
end