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
mcts_params = Dict(:n_iterations=>5000, :depth=>1, :exploration_constant=>70.0)
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params)

r, h = makesim(params; n_runs = 5)
sum(r)./length(r)

h_i = 3
h_mc = h[h_i][1]
h_vi = h[h_i][2]

collect(eachstep(h_mc, "s, a, r, info"))
collect(eachstep(h_vi, "s, a, r, info"))