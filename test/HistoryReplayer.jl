using Random
using POMDPSimulators

@testset "HistoryReplayer.jl" begin
    mg, me = dead_simple_mdps()
    requests = PricingMDP.simulate_trace(mg, MersenneTwister(123))
    
    
    # reward, sales = PricingMDP.evaluate_policy(mg, requests, policy)
    
    
    hrpl = PricingMDP.HistoryReplayer(mg, requests)
    
    # Test basic properties
    @test POMDPs.actions(hrpl) == mg.actions
    @test typeof(hrpl) <:PMDP
    
    # Test gen method
    s = requests[1].s
    (sp, r, info) = POMDPs.gen(hrpl, s, 1000., MersenneTwister(99))
    @test sp == requests[2].s
    @test r == 0.
    @test info == requests[1].info
    
    s = PricingMDP.State(SA[2,3], 5, SA[true, true])
    
    # test the new trace matches the old
    t = PricingMDP.simulate_trace(hrpl, MersenneTwister(321))
    @test t == requests    
    
    # evaluate VI and MCTS with HistoryReplayer
    policy = PricingMDP.get_VI_policy(me)
    hrec = HistoryRecorder(max_steps = mg.T, rng = MersenneTwister(4321)) 
    hᵥ = simulate(hrec, hrpl, policy)
    @test length(hᵥ) == length(requests)
    @test sum(collect(hᵥ[:r])) > 0.

    planner = PricingMDP.get_MCTS_planner(mg; params_mcts = Dict(:rng=>MersenneTwister(1)))
    hₘ = simulate(hrec, hrpl, planner)
    @test length(hₘ) == length(requests)
    @test sum(collect(hₘ[:r])) > 0.
end