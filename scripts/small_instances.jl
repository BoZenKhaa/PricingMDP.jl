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

mdp_params = Dict(:demand => Float64[4,4], :selling_horizon_end => [25,30])
mcts_params = Dict(:n_iterations=>500, :depth=>1, :exploration_constant=>70.0)
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params)

# r, h, mmc, mvi, policy, planner = makesim(params; n_runs = 20)
# display(sum(r)./length(r))

# h_i = 3
# h_mc = h[h_i][1]
# h_vi = h[h_i][2]

# function get_trace(h)
#     [rec for rec in collect(eachstep(h, "s, a, r, info")) if (sum(rec.s.p)>0 || rec.s.t==length(h)-1)]
# end

# display(r[h_i])
# display(get_trace(h_mc))
# display(get_trace(h_vi))

# rng = MersenneTwister(123)
# RolloutEstimator(RandomSolver(rng))