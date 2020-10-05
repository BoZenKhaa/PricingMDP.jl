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
mcts_params = Dict(:n_iterations=>100, :depth=>30, :exploration_constant=>40.0)
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params)
run_vi = true


r,u, hs_mc, hs_vi, mmc, mvi, policy, planner, flat, rs, us = makesim(params; n_runs = 20, vi=run_vi);

display(r)
display(u)

function get_trace(h)
    [rec for rec in collect(eachstep(h, "s, a, r, info")) if (sum(rec.s.p)>0 || rec.s.t==length(h)-1)]
end

h_i = nothing
if h_i ≠ nothing
    h_mc = hs_mc[h_i]
    run_vi ? h_vi = hs_vi[h_i] : nothing

    display((rs[h_i], us[h_i]))
    display(get_trace(h_mc))
    run_vi ? display(get_trace(h_vi)) : nothing
end

# rng = MersenneTwister(123)
# RolloutEstimator(RandomSolver(rng))

