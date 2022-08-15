using RandomNumbers.Xorshifts
using POMDPModelTools

@testset "PMDPe.jl" begin

    # initialize 
    pp = simple_pp()
    rng = Xorshift128Plus(1)
    me = PMDPs.PMDPe(pp)

    @test typeof(me) == PMDPs.PMDPe

    # Test methods
    @testset "states and indices" begin
        tiny_pp = PMDPs.PMDPProblem(
            [PMDPs.Product([true], 3)],
            SA[1],
            BernoulliScheme(3, [0.4]),
            [DiscreteNonParametric([10.0], [1.0])],
            [0.0, 5.0, 10.0, 15.0],
            :revenue,
        )

        tiny_me = PMDPs.PMDPe(tiny_pp)

        states = [
            PMDPs.State(SA[1], 1, 2),
            PMDPs.State(SA[1], 2, 2),
            PMDPs.State(SA[1], 3, 2),
            PMDPs.State(SA[1], 1, 1),
            PMDPs.State(SA[1], 2, 1),
            PMDPs.State(SA[1], 3, 1),
            PMDPs.State(SA[0], 1, 2),
            PMDPs.State(SA[0], 2, 2),
            PMDPs.State(SA[0], 3, 2),
            PMDPs.State(SA[0], 1, 1),
            PMDPs.State(SA[0], 2, 1),
            PMDPs.State(SA[0], 3, 1),
        ]

        @test Set(PMDPs.generate_states(tiny_pp)) == Set(states)

        state_indices = PMDPs.stateindices(tiny_pp)
        @test Set(map(s -> POMDPs.stateindex(tiny_me, s), states)) == Set(1:12)
    end

    # transition
    @testset "POMDPs.transition" begin
        s₀ = PMDPs.State(pp.c₀, 1, 1)
        a = 10.0
        td = POMDPs.transition(me, s₀, a)
        @test isa(td, SparseCat)
        @test length(td.vals) == 8 # requested product is either sold or not and pp has 4 different products (including empty) -> 8 outcomes
        @test sum(td.probs) == 1.0
    end
end
