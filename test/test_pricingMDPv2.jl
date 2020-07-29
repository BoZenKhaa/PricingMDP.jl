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

edges = create_edges(5, 3, [50,60,70,80,90])
products = create_continuous_products(edges)
λ = create_λ(Float64[10,3,3,5,4], products)
mdp = PMDP(edges, products, λ)

#@requirements_info MCTSSolver() mdp State{5}(SA[1,1,1,1,1], 89, SA[0,0,1,1,1])

solver = MCTSSolver(n_iterations=100, 
                    depth=100, 
                    exploration_constant=10.0, 
                    enable_tree_vis=true)
planner = solve(solver, mdp)
s = initialstate(mdp, Random.MersenneTwister(4))
a = action(planner, s)

@test typeof(a)==Float64