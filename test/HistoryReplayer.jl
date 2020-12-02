using Random
using POMDPSimulators
using PricingMDP.LP

@testset "HistoryReplayer.jl" begin
    mg, me = dead_simple_mdps()
    requests = PricingMDP.simulate_trace(mg, MersenneTwister(123))
    
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
    
    # test that the new trace from replayer matches the input trace
    t = PricingMDP.simulate_trace(hrpl, MersenneTwister(321))
    @test t == requests    

    # TODO: The following should likely be tested in tests of the specific policies

    hrec = HistoryRecorder(max_steps = mg.T, rng = MersenneTwister(4321)) 
    
    # test VI with HistoryReplayer
    policy = PricingMDP.get_VI_policy(me)
    hᵥ = simulate(hrec, hrpl, policy)
    @test length(hᵥ) == length(requests)
    @test sum(collect(hᵥ[:r])) > 0.

    # test MCTS with historyReplayer
    planner = PricingMDP.get_MCTS_planner(mg; params_mcts = Dict(:rng=>MersenneTwister(1)))
    hₘ = simulate(hrec, hrpl, planner)
    @test length(hₘ) == length(requests)
    @test sum(collect(hₘ[:r])) > 0.

    # test hindsight with historyReplayer
    hindsight = PricingMDP.LP.get_MILP_hindsight_policy(mg, requests)
    hₕ = simulate(hrec, hrpl, hindsight)
    @test length(hₕ) == length(requests)
    @test sum(collect(hₕ[:r])) > 0.   

    # test flatrate with historyReplayer
    # R, U = PricingMDP.optimize_flatrate_policy(mg, [requests, requests])
    flatrate = PricingMDP.get_flatrate_policy(mg, [requests, requests])
    hᵣ = simulate(hrec, hrpl, flatrate)
    @test length(hᵣ) == length(requests)
    @test sum(collect(hᵣ[:r])) > 0.   

end