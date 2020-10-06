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

using DrWatson
using Distributions
using BeliefUpdaters

mdp_params = Dict(pairs( (n_edges = 2, c_init = 2, demand = Float64[4,4], selling_horizon_end = [25,30], actions = 15:45)))
# mcts_params = Dict(solver= MCTSSolver, n_iterations=1000, depth=30, exploration_constant=40.0, reuse_tree=true)
mcts_params = Dict(pairs( (solver= DPWSolver, n_iterations=10, depth=30, exploration_constant=40.0, keep_tree=true, show_progress=false)))
exp_params = Dict(pairs((n_runs = 2, vi=true, save=:stats)))
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params, :exp=>exp_params)

result, filepath =  makesim(params);

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
using Distributions
using BeliefUpdaters
mdp_dir = readdir(datadir("sims"))[1]
exp = readdir(datadir("sims", mdp_dir))[1]
res = wload(datadir("sims", mdp_dir, exp))

# # analyze results
using DataFrames

df = collect_results(
    datadir("sims", mdp_dir);
    white_list = [:r, :u, :t]
)


# rng = MersenneTwister(123)
# RolloutEstimator(RandomSolver(rng))
