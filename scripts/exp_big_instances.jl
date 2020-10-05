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

mdp_params = Dict(:n_edges => 12, :c_init => 10,  :demand => Float64[5,2,2,2,2,2,2,2,2,4], :selling_horizon_end => collect(910:10:1000), :actions=> [0,collect(15:2:300)...,1000])
mcts_params = Dict(:n_iterations=>5000, :depth=>30, :exploration_constant=>40.0)
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params)

r, h, mmc, mvi, policy, planner, flat_r_a = makesim(params; n_runs = 20, vi=false)
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
