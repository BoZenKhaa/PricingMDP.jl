using RandomNumbers.Xorshifts

@testset "PMDPe.jl" begin

    # initialize 
    pp = simple_pp()
    rng = Xorshift128Plus(1)
    me = PMDPs.PMDPe(pp)

    @test typeof(me, PMDPs.PMDPe)

    # Test methods
   
    s = PMDPs.State(pp.c₀, 1, 1)

    sₑ = PMDPs.State(pp.c₀, 1, mg.empty_product_id)
    

end