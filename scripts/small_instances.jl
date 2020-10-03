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

mdp_params = Dict(:demand => Float64[4,4], :selling_horizon_end => [25,30], :actions=> [0,collect(15:45)...,1000])
mcts_params = Dict(:n_iterations=>5000, :depth=>30, :exploration_constant=>40.0)
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params)

r, h, mmc, mvi, policy, planner, flat_r_a = makesim(params; n_runs = 20)
display(maximum(sum(flat_r_a)/length(flat_r_a)))
display(sum(r)./length(r))

h_i = 3
h_mc = h[h_i][1]
h_vi = h[h_i][2]

function get_trace(h)
    [rec for rec in collect(eachstep(h, "s, a, r, info")) if (sum(rec.s.p)>0 || rec.s.t==length(h)-1)]
end

display(r[h_i])
display(get_trace(h_mc))
display(get_trace(h_vi))

# rng = MersenneTwister(123)
# RolloutEstimator(RandomSolver(rng))
