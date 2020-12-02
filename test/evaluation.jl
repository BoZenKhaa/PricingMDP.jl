using Random
using POMDPSimulators

@testset "evalution.jl" begin
    mg, me = dead_simple_mdps()
    requests = PricingMDP.simulate_trace(mg, MersenneTwister(123))
    policy = PricingMDP.get_VI_policy(me)


    # reward, sales = PricingMDP.evaluate_policy(mg, requests, policy)


    hrpl = PricingMDP.HistoryReplayer(mg, requests)
    
    @test POMDPs.actions(hrpl) == mg.actions
    @test typeof(hrpl) <:PMDP

    s = PricingMDP.State(SA[2,3], 5, SA[true, true])
    @test PricingMDP.sale_impossible(hrpl, s) == false
    @test PricingMDP.isterminal(hrpl, s) == false

    t = PricingMDP.simulate_trace(hrpl, MersenneTwister(123))
   
    @test t == requests    

    # hrec = HistoryRecorder(max_steps = mg.T, rng = MersenneTwister(12345))
   
    





    # history = simulate(hrec, hrpl, policy)

    # planner = PricingMDP.get_MCTS_planner(mg)

end