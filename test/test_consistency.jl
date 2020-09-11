using PricingMDP
using Test

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

using Traceur
using XLSX
using BSON


mdp_vi = PricingMDP.create_PMDP(PMDPe)
mdp_mc = PricingMDP.create_PMDP(PMDPg) 

policy = PricingMDP.get_VI_policy(mdp_vi)
planner = PricingMDP.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(1234)

@test rand(rng, initialstate(mdp_mc)) == rand(rng, initialstate(mdp_vi))