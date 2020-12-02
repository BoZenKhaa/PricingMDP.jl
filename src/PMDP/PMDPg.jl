"""
Structures and functions for the GENERATIVE POMDPs.jl interface of the Pricing MDP
"""

"""
m = PMDPg(edges, products, λ)

PMDP for generative interface
"""
struct PMDPg <: PMDP{State, Action}
    n_edges::Int64
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product}
    λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    selling_period_ends::Array{Timestep} # Selling period end for each product
    empty_product::Product
    B::Array{Distribution} # User budgets
    actions::Array{Action}
    objective::Symbol
    productindices::Dict
    
    function PMDPg(E, P, λ, B, A, objective)
        selling_period_ends = get_product_selling_period_ends(E, P)
        T = selling_period_ends[1]
        empty_product=P[1]
        @assert objective in [:revenue, :utilization]
        pi = productindices(P)
        return new(length(E), T,E,P,λ, selling_period_ends, empty_product,B, A, objective, pi)
    end
end

"""
Returns next requested product. If in given timestep one of the prodcuts has selling period end, update the product request probs.

TODO: Potential speedup if product_request_probs are not recalculated at every step
"""
function sample_request(m::PMDPg, t::Timestep, rng::AbstractRNG)
    product_request_probs = calculate_product_request_probs(t, m.λ, m.selling_period_ends)
    d_demand_model = Categorical(product_request_probs)
    prod_index = rand(rng, d_demand_model)
    return m.P[prod_index]
end

"""
Sample user budget Budget for product requested in state s.
"""
function sample_customer_budget(m::PMDPg, s::State, rng::AbstractRNG)::Float64
    # local b::Float64
    if s.p != m.P[1]
        budget_distribution = m.B[index(m, s.p)]
        budget = rand(rng, budget_distribution)
    else
        budget = -1.
    end
    return budget
end

