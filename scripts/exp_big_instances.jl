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

mdp_params = Dict(:n_edges => 12, :c_init => 10,  :demand => Float64[5,2,2,2,2,2,2,2,2,2,2,24], :selling_horizon_end => collect(890:10:1000), :actions=> [0,collect(15:2:300)...,10000])
map(length, values(mdp_params))
sum(mdp_params[:demand])
# mcts_params = Dict(:solver=> MCTSSolver, :n_iterations=>1000, :depth=>30, :exploration_constant=>40.0, :reuse_tree=>true)
mcts_params = Dict(:solver=> DPWSolver, :n_iterations=>5000, :depth=>500, :exploration_constant=>40.0, :keep_tree=>true, :show_progress=>true)
params = Dict(:mdp=>mdp_params, :mcts=>mcts_params)
run_vi = false

r,u, hs_mc, hs_vi, mmc, mvi, policy, planner, flat, rs, us = makesim(params; n_runs = 1, vi=run_vi);

println()
display("rewards: $r")
display("utilization: $u")

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