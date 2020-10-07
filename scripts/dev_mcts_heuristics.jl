using PricingMDP
using Test
using POMDPSimulators

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
# using Plots
using POMDPSimulators
# using D3Trees
using POMDPPolicies
using POMDPLinter
using Random
using DataFrames
using POMDPSimulators

"""
Options
1) Rollout policy
2) Initialize N and Q
"""


mdp_vi = PricingMDP.create_PMDP(PMDPe)
mdp_mc = PricingMDP.create_PMDP(PMDPg) 

policy = PricingMDP.get_VI_policy(mdp_vi)
# planner = PricingMDP.get_MCTS_planner(mdp_mc)

solver = MCTSSolver(n_iterations=5000,
                    depth=4, 
                    exploration_constant=50.0, 
                    enable_tree_vis=true)
planner = solve(solver, mdp_mc);

rng = MersenneTwister(1234)

PricingMDP.compare_actions(mdp_vi, policy, planner; rng_seed=123, verbose=true)

mdp_mc = PricingMDP.create_PMDPe10(PMDPg) 
s0 = rand(rng, initialstate(mdp_mc))
solver = MCTSSolver(n_iterations=5000,
                    depth=1, 
                    exploration_constant=50.0, 
                    enable_tree_vis=true)
planner = solve(solver, mdp_mc);
action(planner, s0)

rng = MersenneTwister(123)
hr = HistoryRecorder(max_steps=1000, capture_exception=true, rng=rng)
h = simulate(hr, mdp_mc, planner)

# PricingMDP.run_sim(mdp_mc, planner)
# s0 = rand(rng, initialstate(mdp_mc))

# function run_sim(mdp::PMDP, policy::Policy; rng_seed=1234)
#     rng = MersenneTwister(rng_seed)
#     hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
#     h = simulate(hr, mdp, policy)
#     collect(eachstep(h, "s, a, r, user_budget"))
#     # sum(h[:r])
# end

# rng = MersenneTwister(12)
# hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
# h = simulate(hr, mdp_mc, planner)
# collect(eachstep(h, "s, a, r, info"))

# @show run_sim(mdp_mc, policy; rng_seed = 1235)

# ch = run_sim(mdp_mc, planner; rng_seed = 1236)
# @show ch
# any(ch[end][:s].c .< 0)


# for i in 1:10000
#     ch = run_sim(mdp_vi, planner; rng_seed = i)
#     print(i, " ")
#     any(ch[end][:s].c .< 0) ? break : continue
# end
# action(planner, s0)