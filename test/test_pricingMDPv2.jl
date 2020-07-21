using PricingMDP.PricingMDPv2

using StaticArrays
using MCTS

edges = create_edges(5, 3, [50,60,70,80,90])
products = create_continuous_products(edges)
λ = create_λ(Float64[10,3,3,5,4], products)
mdp = PMDPv2(edges, products, λ)

solver = MCTSSolver(n_iterations=100, depth=100, exploration_constant=10.0)
planner = solve(solver, mdp)
s = State(SA[1,1,1,1,1], 0, SA[1,0,0,1,1])
a = action(planner, s)
println("Action:")
println(a)
println("State:")
println(s)

s_actions = zeros(500)
for i in 1:500
    a = action(planner, s)
    s_actions[i]=a
end

# println(s_actions)

using StatsBase
using Plots


display(bar(countmap(s_actions)))
println(countmap(s_actions))
println(mean(s_actions))
# display(plot(s_actions))
