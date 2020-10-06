using PricingMDP
using Test
using POMDPSimulators

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
using Plots
using POMDPSimulators
using D3Trees
using POMDPPolicies
using POMDPLinter
using Random
using DataFrames
using POMDPSimulators

"""
n_edges = 2, 
c_init = 2,  
selling_horizon_end = [10,10], 
demand = Float64[2,2], 
user_budgets = BudgetPerUnit(Distributions.Uniform(5,30)), 
actions =  Action[0,15,30,45,1000]
"""


for n_iter in [10,100,1000,5000,10000]
    println("Processng n_iter=$n_iter")
    mdp_params = Dict(pairs((n_edges = 10, c_init = 10,  demand = Float64[3,1,1,1,1,1,1,1,1,8], selling_horizon_end = collect(155:5:200), actions= 15:2:300)))
    # mcts_params = Dict(pairs((solver= MCTSSolver, n_iterations=5000, depth=500, exploration_constant=40.0, reuse_tree=true)))
    exp_params = Dict(pairs((n_runs = 10, vi=false, save=:stats)))
    mcts_params = Dict(pairs((solver= DPWSolver, n_iterations=n_iter, depth=100, exploration_constant=40.0, keep_tree=true, show_progress=false)))
    params = Dict(:mdp=>mdp_params, :mcts=>mcts_params, :exp=>exp_params)
    
    result, filepath =  makesim(params);
    
    r = result[:r] 
    u = result[:u]
    result[:t]

    println()
    display("rewards: $r")
    display("utilization: $u")
end


# map(length, values(mdp_params))
# sum(mdp_params[:demand])

# # analyze results
mdp_dir = readdir(datadir("sims"))[1]
exp = readdir(datadir("sims", mdp_dir))[1]
# res = wload(datadir("sims", mdp_dir, exp))

df = collect_results(
    datadir("sims", mdp_dir);
    white_list = [:r, :u, :t]
)