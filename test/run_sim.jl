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


mdp_vi = PricingMDP.create_PMDP(PMDPe)
mdp_mc = PricingMDP.create_PMDP(PMDPg) 

policy = PricingMDP.get_VI_policy(mdp_vi)
planner = PricingMDP.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(1234)

s0 = rand(rng, initialstate(mdp_mc))

# function run_sim(mdp::PMDP, policy::Policy; rng_seed=1234)
#     rng = MersenneTwister(rng_seed)
#     hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
#     h = simulate(hr, mdp, policy)
#     collect(eachstep(h, "s, a, r, user_budget"))
#     # sum(h[:r])
# end

rng = MersenneTwister(12)
hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
h = simulate(hr, mdp_mc, planner)
collect(eachstep(h, "s, a, r, info"))

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