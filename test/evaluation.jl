using Random
using POMDPSimulators

@testset "evalution.jl" begin
    mg, me = dead_simple_mdps()
    h = PricingMDP.simulate_trace(mg, MersenneTwister(12))
    
    policy = PricingMDP.get_VI_policy(me)

    



    planner = PricingMDP.get_MCTS_planner(mg)

end