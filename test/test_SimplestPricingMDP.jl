using PricingMDP.SimplestPricingMDP

using POMDPs
using StaticArrays
using MCTS

mdp = SPMDP()
solver = MCTSSolver(n_iterations=100, depth=20, exploration_constant=5.0)
planner = solve(solver, mdp)

# a = action(planner, SA[29,1])

@requirements_info MCTSSolver() SimplestPricingMDP.SPMDP() SVector{2,Int64}
