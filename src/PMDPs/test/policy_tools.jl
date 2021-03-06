using Random
# using POMDPSimulators
using MCTS

function simple_mdps()
    pp = simple_pp()
    PMDPs.PMDPg(pp), PMDPs.PMDPe(pp)
end

@testset "policy_tools.jl" begin
    mg, me = simple_mdps()
    s₀ = rand(POMDPs.initialstate(mg))
    
    policy = PMDPs.get_VI_policy(me)
    @test isa(policy, Policy)
    @test isa(action(policy,s₀), PMDPs.Action)
    
    planner = PMDPs.get_MCTS_planner(mg)
    @test isa(planner, Policy)
    @test isa(action(planner,s₀), PMDPs.Action)
    
    params_mcts = Dict(pairs( (solver= DPWSolver, n_iterations=50, depth=30, exploration_constant=40.0, enable_state_pw = true, keep_tree=true, show_progress=false)))
    planner2 = PMDPs.get_MCTS_planner(mg; params_mcts)
    @test isa(planner2, Policy)
    @test isa(action(policy,s₀), PMDPs.Action)
    
end