using RandomNumbers.Xorshifts
using POMDPModelTools

@testset "PMDPe.jl" begin

    # initialize 
    pp = simple_pp()
    rng = Xorshift128Plus(1)
    me = PMDPs.PMDPe(pp)

    @test typeof(me) == PMDPs.PMDPe

    # Test methods
   
    s₀ = PMDPs.State(pp.c₀, 1, 1)
    a = 10.
    td = POMDPs.transition(me, s₀, a)
    @test isa(td, SparseCat)
    @test length(td.vals) == 8 # requested product is either sold or not and pp has 4 different products (including empty) -> 8 outcomes
    @test sum(td.probs) == 1.
end