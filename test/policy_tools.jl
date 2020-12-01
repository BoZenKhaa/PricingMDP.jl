using Random
# using POMDPSimulators
using MCTS

@testset "policy_tools.jl" begin
    mg, me = dead_simple_mdps()
    s₀ = rand(POMDPs.initialstate(mg))
    
    policy = PricingMDP.get_VI_policy(me)
    @test isa(policy, Policy)
    @test isa(action(policy,s₀), PricingMDP.Action)
    
    planner = PricingMDP.get_MCTS_planner(mg)
    @test isa(planner, Policy)
    @test isa(action(planner,s₀), PricingMDP.Action)
    
    params_mcts = Dict(pairs( (solver= DPWSolver, n_iterations=50, depth=30, exploration_constant=40.0, enable_state_pw = true, keep_tree=true, show_progress=false)))
    planner2 = PricingMDP.get_MCTS_planner(mg; params_mcts)
    @test isa(planner2, Policy)
    @test isa(action(policy,s₀), PricingMDP.Action)
    
end