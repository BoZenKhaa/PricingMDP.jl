using PMDPs

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
using Plots
using POMDPTools
using D3Trees
using POMDPTools
using Random

using Traceur

edges = create_edges(5, 3, [50, 60, 70, 80, 90])
products = create_continuous_products(edges)
λ = create_λ(Float64[10, 3, 3, 5, 4], products)
mdp = PMDP(edges, products, λ)

# @requirements_info ValueIterationSolver() mdp
@requirements_info MCTSSolver() mdp State{5}(SA[1, 1, 1, 1, 1], 89, SA[0, 0, 1, 1, 1])

solver = MCTSSolver(
    n_iterations = 100,
    depth = 100,
    exploration_constant = 10.0,
    enable_tree_vis = true,
)
planner = solve(solver, mdp)
s = initialstate(mdp, Random.MersenneTwister(4))
a = action(planner, s)
println("Action:")
println(a)
println("State:")
println(s)

s_actions = zeros(500)
for i = 1:10
    a = action(planner, s)
    s_actions[i] = a
end

# println(s_actions)

display(bar(countmap(s_actions)))
println(countmap(s_actions))
println(mean(s_actions))
# display(plot(s_actions))

rand_policy = RandomPolicy(mdp)

# hr = HistoryRecorder(max_steps=100)
# history = simulate(hr, mdp,  )

initial_state = State([5, 5, 5, 5, 5], 0, [0, 0, 0, 0, 0])
rollout_sim = RolloutSimulator(max_steps = 10)
r_mcts = simulate(rollout_sim, mdp, planner, initial_state)
r_rand = simulate(rollout_sim, mdp, rand_policy, initial_state)


initial_state = State{5}(SA[5, 5, 5, 5, 5], 0, SA[0, 0, 0, 0, 0])
hr = HistoryRecorder(max_steps = 30)
h_mcts = simulate(hr, mdp, planner, initial_state)
h_rand = simulate(hr, mdp, rand_policy, initial_state)

@show state_hist(h_mcts)
@show collect(action_hist(h_mcts))
