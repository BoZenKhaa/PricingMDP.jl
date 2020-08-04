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

include("PMDP_instances/e5.jl")

#@requirements_info MCTSSolver() mdp State{5}(SA[1,1,1,1,1], 89, SA[0,0,1,1,1])

solver = MCTSSolver(n_iterations=100, 
                    depth=100, 
                    exploration_constant=10.0, 
                    enable_tree_vis=true)
planner = solve(solver, mdp)
s = initialstate(mdp, Random.MersenneTwister(4))
a = action(planner, s)

@test typeof(a)==Float64