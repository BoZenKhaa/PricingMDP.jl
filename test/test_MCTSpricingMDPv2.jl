using PricingMDP

using StaticArrays
using POMDPs
using MCTS#, DiscreteValueIteration
# using StatsBase
# using Plots
# using POMDPSimulators
# using D3Trees
# using POMDPPolicies
using Random
using Test

# using Traceur

mdp = PricingMDP.create_PMDPe2(PMDPg)

s = initialstate(mdp, Random.MersenneTwister(4))

solver = MCTSSolver(n_iterations=100, 
                    depth=100, 
                    exploration_constant=10.0, 
                    enable_tree_vis=true)

POMDPs.@show_requirements POMDPs.solve(solver, mdp)

planner = solve(solver, mdp)

a = POMDPs.action(planner, s)

@test typeof(a)==Float64