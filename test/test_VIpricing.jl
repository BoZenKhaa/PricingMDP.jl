using PricingMDP

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

using Traceur
using XLSX

include("PMDP_instances/e2.jl")

# POMDPLinter.@requirements_info SparseValueIterationSolver() mdp
# @requirements_info ValueIterationSolver() mdp

solver = ValueIterationSolver(max_iterations=100, belres=1e-6, verbose=true) # creates the solver
POMDPs.@show_requirements POMDPs.solve(solver, mdp)

println("Solving...")
policy = solve(solver, mdp)
println("Done.")

# Get action counts
df = DataFrame(pricei = policy.policy)
df[:, :price] = [policy.action_map[i] for i in df.pricei]
combine(groupby(df, :price), nrow)


qmat = policy.qmat
non_zero_Q_states = (sum(qmat, dims = 2).>0)[:,1]
qmat[non_zero_Q_states, :]

qdf = DataFrame(hcat( [repr(mdp.states[i]) for i in 1:length(mdp.states)], policy.qmat), map(Symbol, vcat(["state"], policy.action_map)))

XLSX.writetable("q_mat.xlsx", qdf)

# @requirements_info MCTSSolver() mdp State{5}(SA[1,1,1,1,1], 89, SA[0,0,1,1,1])

# solver = MCTSSolver(n_iterations=100, 
#                     depth=100, 
#                     exploration_constant=10.0, 
#                     enable_tree_vis=true)
# planner = solve(solver, mdp)
# s = initialstate(mdp, Random.MersenneTwister(4))
# a = action(planner, s)
# println("Action:")
# println(a)
# println("State:")
# println(s)

# s_actions = zeros(500)
# for i in 1:10
#     a = action(planner, s)
#     s_actions[i]=a
# end

# # println(s_actions)

# display(bar(countmap(s_actions)))
# println(countmap(s_actions))
# println(mean(s_actions))
# # display(plot(s_actions))

# rand_policy = RandomPolicy(mdp)

# # hr = HistoryRecorder(max_steps=100)
# # history = simulate(hr, mdp,  )
 
# initial_state = State{5}(SA[5,5,5,5,5], 0, SA[0,0,0,0,0])
# rollout_sim = RolloutSimulator(max_steps=10)
# r_mcts = simulate(rollout_sim, mdp, planner, initial_state)
# r_rand = simulate(rollout_sim, mdp, rand_policy, initial_state)


# initial_state = State{5}(SA[5,5,5,5,5], 0, SA[0,0,0,0,0])
# hr = HistoryRecorder(max_steps=30)
# h_mcts = simulate(hr, mdp, planner, initial_state)
# h_rand = simulate(hr, mdp, rand_policy, initial_state)

# @show state_hist(h_mcts)
# @show collect(action_hist(h_mcts)