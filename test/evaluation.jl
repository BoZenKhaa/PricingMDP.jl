using Random
using POMDPSimulators

@testset "evalution.jl" begin
    mg, me = dead_simple_mdps()
    requests = PricingMDP.simulate_trace(mg, MersenneTwister(123))
    
    policy = PricingMDP.get_VI_policy(me)


    reward, sales = PricingMDP.evaluate_policy(mg, requests, policy)

    @show reward, sales
    @show requests

    planner = PricingMDP.get_MCTS_planner(mg)

end