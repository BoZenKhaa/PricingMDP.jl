using MCTS
using POMDPs
using POMDPModels
using D3Trees
using Random

using BenchmarkTools
# Benchmark on simple pricing problem

n_iter = 1000
depth = 10
ec = 10.0

solver = MCTSSolver(
    n_iterations=n_iter,
    depth=depth,
    exploration_constant=ec,
    enable_tree_vis=true,
    sizehint=100_000
)
mdp = SimpleGridWorld()

planner = solve(solver, mdp)
state = rand(Random.MersenneTwister(4), initialstate(mdp))

a = action(planner, state)

GC.enable_logging(false)

@benchmark POMDPs.action($planner, $state)

