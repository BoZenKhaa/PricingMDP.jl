using PMDPs
using Test
using POMDPTools

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
using Plots
using POMDPTools
using D3Trees
using POMDPTools
using POMDPLinter
using Random
using DataFrames
using POMDPTools


mdp_vi = PMDPs.create_PMDP(PMDPe)
mdp_mc = PMDPs.create_PMDP(PMDPg)

policy = PMDPs.get_VI_policy(mdp_vi)
planner = PMDPs.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(1234)

# s0 = rand(rng, initialstate(mdp_mc))

# function run_sim(mdp::PMDP, policy::Policy; rng_seed=1234)
#     rng = MersenneTwister(rng_seed)
#     hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
#     h = simulate(hr, mdp, policy)
#     collect(eachstep(h, "s, a, r, user_budget"))
#     # sum(h[:r])
# end

# rng = MersenneTwister(rand_seed)
# hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
# h_mc = simulate(hr, mdp_mc, planner)
# collect(eachstep(h, "s, a, r, info"))

rng_seed = 1
max_steps = mdp_mc.T + 1

h_mc = run_sim(mdp_mc, planner; max_steps = max_steps, rng_seed = rng_seed)
h_vi = run_sim(mdp_mc, policy; max_steps = max_steps, rng_seed = rng_seed)

hindsight = PMDPs.LP.MILP_hindsight_pricing(
    mdp_mc,
    h_mc;
    optimization_goal = "revenue",
    verbose = false,
)
flatrate = PMDPs.flatrate_pricing(mdp_mc, h_mc)

hindsight, flatrate, get_stats(h_mc), get_stats(h_vi)
