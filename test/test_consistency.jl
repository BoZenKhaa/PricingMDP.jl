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

@test rand(rng, initialstate(mdp_mc)) == rand(rng, initialstate(mdp_vi))

s0 = rand(rng, initialstate(mdp_mc))

hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
h = simulate(hr, mdp_vi, policy)
collect(eachstep(h, "s, a, r"))
sum(h[:r])


hr2 = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
h2 = simulate(hr2, mdp_mc, planner)

action(planner, s0)