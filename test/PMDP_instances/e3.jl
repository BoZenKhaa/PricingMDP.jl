using PricingMDP
using StaticArrays
using POMDPs
using POMDPModelTools


n_edges = 3
c_init = 2
selling_horizon_end = [50,60,70]
demand = Float64[5,3,1]

edges = create_edges(n_edges, c_init, selling_horizon_end)
products = create_continuous_products(edges)
λ = create_λ(demand, products)

# POMDPs.actions(m::PMDP) = Action[1:5:100;]
POMDPs.actions(m::PMDP, s::State) = POMDPs.actions(m::PMDP, s::State; actions = Action[0:5:100;])
POMDPs.initialstate_distribution(m::PMDP) = Deterministic(State{n_edges}(@SVector(fill(c_init, n_edges)), 0, @SVector(fill(false, n_edges))))

mdp = PMDP(edges, products, λ)

