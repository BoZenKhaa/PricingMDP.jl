using PricingMDP.PricingMDPv2

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
using Plots
using POMDPSimulators
using D3Trees
using POMDPPolicies
using Random

import Base.show

edges = create_edges(5, 3, [50,60,70,80,90])
products = create_continuous_products(edges)
λ = create_λ(Float64[10,3,3,5,4], products)
mdp = PMDPv2(edges, products, λ)

# @requirements_info ValueIterationSolver() mdp
@requirements_info MCTSSolver() mdp State(SA[1,1,1,1,1], 89, SA[0,0,1,1,1])

solver = MCTSSolver(n_iterations=100, 
                    depth=100, 
                    exploration_constant=10.0, 
                    enable_tree_vis=true)
planner = solve(solver, mdp)
s = initialstate(mdp, Random.MersenneTwister(4))
a = action(planner, s)
println("Action:")
println(a)
println("State:")
println(s)

s_actions = zeros(500)
for i in 1:10
    a = action(planner, s)
    s_actions[i]=a
end

# println(s_actions)

display(bar(countmap(s_actions)))
println(countmap(s_actions))
println(mean(s_actions))
# display(plot(s_actions))

rand_policy = RandomPolicy(mdp)

# hr = HistoryRecorder(max_steps=100)
# history = simulate(hr, mdp,  )
 
initial_state = State(SA[5,5,5,5,5], 0, SA[0,0,0,0,0])
rollout_sim = RolloutSimulator(max_steps=10)
r_mcts = simulate(rollout_sim, mdp, planner, initial_state)
r_rand = simulate(rollout_sim, mdp, rand_policy, initial_state)


initial_state = State(SA[5,5,5,5,5], 0, SA[0,0,0,0,0])
hr = HistoryRecorder(max_steps=30)
h_mcts = simulate(hr, mdp, planner, initial_state)
h_rand = simulate(hr, mdp, rand_policy, initial_state)

@show state_hist(h_mcts)
@show collect(action_hist(h_mcts))

state = initialstate(mdp, Random.MersenneTwister(4))
D3Tree(planner, state, init_expand=2)