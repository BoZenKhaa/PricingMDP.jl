using PMDPs
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

using DrWatson
using Distributions
using BeliefUpdaters

"""
n_edges = 2, 
c_init = 2,  
selling_horizon_end = [10,10], 
demand = Float64[2,2], 
user_budgets = BudgetPerUnit(Distributions.Uniform(5,30)), 
actions =  Action[0,15,30,45,1000]
"""
# params_mcts = Dict(pairs((solver= DPWSolver, n_iterations=1, depth=100, exploration_constant=40.0, keep_tree=true, show_progress=false)))
# params_mdp = Dict(pairs( (n_edges = 10, c_init = 30,  demand = 5*Float64[1,1,1,1,1,1,1,1,1,1], selling_horizon_end = collect(155:5:200), actions= 15:2:300, objective=:revenue)))
# mdp_mc = PMDPs.create_PMDP(PMDPg; params_mdp...) 
# planner = PMDPs.get_MCTS_planner(mdp_mc, params_mcts)
# h_mc = run_sim(mdp_mc, planner; max_steps = 201, rng_seed = 1)


for d in [7500, 10000, 12500]
    println("Processng $d")
    # mdp_params = Dict(pairs( (n_edges = 3, c_init = 2, demand = 5*Float64[1,1,1], selling_horizon_end = [40,45,50], actions = 15:5:90, objective=:utilization)))
    mdp_params = Dict(
        pairs((
            n_edges = 10,
            c_init = 30,
            demand = 5 * Float64[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            selling_horizon_end = collect(155:5:200),
            actions = 15:2:300,
            objective = :revenue,
        )),
    )
    # mcts_params = Dict(pairs((solver= MCTSSolver, n_iterations=5000, depth=500, exploration_constant=40.0, reuse_tree=true)))
    exp_params = Dict(pairs((n_runs = 10, vi = false, save = :stats)))
    mcts_params = Dict(
        pairs((
            solver = DPWSolver,
            n_iterations = d,
            depth = 100,
            exploration_constant = 40.0,
            keep_tree = true,
            show_progress = false,
        )),
    )
    params = Dict(:mdp => mdp_params, :mcts => mcts_params, :exp => exp_params)

    result, filepath = makesim(params)

    r = result[:r]
    u = result[:u]
    result[:t]

    println()
    display("rewards: $r")
    display("utilization: $u")
end

# for d in 5:1:6
#     println("Processing $d")
#     mdp_params = Dict(pairs( (n_edges = 3, c_init = 2, demand = 5*Float64[1,1,1], selling_horizon_end = [40,45,50], actions = 15:5:90, objective=:utilization)))
#     #mdp_params = Dict(pairs( (n_edges = 2, c_init = 1, demand = Float64[1,1], selling_horizon_end = [20,25], actions = 15:5:30)))
#     # mcts_params = Dict(solver= MCTSSolver, n_iterations=1000, depth=30, exploration_constant=40.0, reuse_tree=true)
#     mcts_params = Dict(pairs( (solver= DPWSolver, n_iterations=d, depth=30, exploration_constant=40.0, enable_state_pw = true, keep_tree=true, show_progress=false)))
#     exp_params = Dict(pairs((n_runs = 10, vi=true, save=:stats)))
#     params = Dict(:mdp=>mdp_params, :mcts=>mcts_params, :exp=>exp_params)

#     result, filepath =  makesim(params);

#     r = result[:r] 
#     u = result[:u]
#     result[:t]
#     println()
#     display("rewards: $r")
#     display("utilization: $u")
# end



# map(length, values(mdp_params))
# sum(mdp_params[:demand])

# # analyze results
mdp_dir = readdir(datadir("sims"))[2]
exp = readdir(datadir("sims", mdp_dir))[1]
# res = wload(datadir("sims", mdp_dir, exp))

df = collect_results(datadir("sims", mdp_dir); white_list = [:r, :u, :t, :params])
df
