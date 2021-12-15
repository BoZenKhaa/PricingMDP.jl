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


println("Processing")
mdp_params = Dict(
    pairs((
        n_edges = 3,
        c_init = 2,
        demand = Float64[1, 1, 1],
        selling_horizon_end = [40, 45, 50],
        actions = 15:5:90,
        objective = :revenue,
    )),
)
#mdp_params = Dict(pairs( (n_edges = 2, c_init = 1, demand = Float64[1,1], selling_horizon_end = [20,25], actions = 15:5:30)))
# mcts_params = Dict(solver= MCTSSolver, n_iterations=1000, depth=30, exploration_constant=40.0, reuse_tree=true)
mcts_params = Dict(
    pairs((
        solver = DPWSolver,
        n_iterations = 50,
        depth = 30,
        exploration_constant = 40.0,
        enable_state_pw = true,
        keep_tree = true,
        show_progress = false,
    )),
)
exp_params = Dict(pairs((n_runs = 20, vi = true, save = :stats)))
params = Dict(:mdp => mdp_params, :mcts => mcts_params, :exp => exp_params)

result, filepath = makesim(params);

r = result[:r]
u = result[:u]
result[:t]
println()
display("rewards: $r")
display("utilization: $u")


# function get_trace(h)
#     [rec for rec in collect(eachstep(h, "s, a, r, info")) if (sum(rec.s.p)>0 || rec.s.t==length(h)-1)]
# end

# h_i = nothing
# if h_i ≠ nothing
#     h_mc = hs_mc[h_i]
#     run_vi ? h_vi = hs_vi[h_i] : nothing

#     display((rs[h_i], us[h_i]))
#     display(get_trace(h_mc))
#     run_vi ? display(get_trace(h_vi)) : nothing
# end

# # Load results
# using Distributions
# using BeliefUpdaters
# res_foldername = readdir(datadir("sims", "exp_small_u"))[1]
# exp_file = readdir(datadir("sims", "tst"))[1]
# res = wload(datadir("sims", "tst", "tst.bson"))

# # # analyze results
# using DataFrames

# df = collect_results(
#     datadir("sims", "exp_small_u"),
#     white_list = [:r, :u, :t, :params], subfolders=true
# )


# rng = MersenneTwister(123)
# RolloutEstimator(RandomSolver(rng))
