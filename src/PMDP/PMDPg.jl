"""
Structures and functions for the GENERATIVE POMDPs.jl interface of the Pricing MDP
"""

"""
m = PMDPg(edges, products, λ)

PMDP for generative interface
"""
struct PMDPg <: PMDP{State, Action}
    pp::PMDPProblem                # Pricing Problem
    nᵣ::Int64
    # T::Timestep                  # max timestep
    # E::Array{Edge}
    # P::Array{Product}
    # λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    # selling_period_ends::Array{Timestep} # Selling period end for each product
    empty_product::Product
    empty_product_id::Int64
    # B::Array{Distribution} # User budgets
    # actions::Array{Action}
    # objective::Symbol
    # productindices::Dict
    
    function PMDPg(pp)
        nᵣ = size(pp.c₀)[1]
        empty_product = Product(falses(nᵣ), selling_period_end(pp))
        new(pp, nᵣ, empty_product, n_products(pp)+1)
    end

    # function PMDPg(E, P, λ, B, A, objective)
    #     # selling_period_ends = get_product_selling_period_ends(E, P)
    #     T = selling_period_ends[1]
    #     empty_product=P[1]
    #     @assert objective in [:revenue, :utilization]
    #     pi = productindices(P)
    #     return new(length(E), T,E,P,λ, selling_period_ends, empty_product,B, A, objective, pi)
    # end
end

"""
Returns next requested product. If in given timestep one of the prodcuts has selling period end, update the product request probs.

TODO: Potential speedup if product_request_probs are not recalculated at every step
"""
function sample_request(m::PMDPg, t::Timestep, rng::AbstractRNG)::Product
    prod_index = rand(rng, demand(m)[t])
    prod_index == n_products(problem(m))+1 ? p = empty_product(m) : p = products(m)[prod_index]
    return p
end

"""
Sample user budget Budget for product requested in state s.
"""
function sample_customer_budget(m::PMDPg, s::State, rng::AbstractRNG)::Action
    # local b::Float64
    if s.iₚ != m.empty_product_id
        budget_distribution = budgets(m)[s.iₚ]
        budget = rand(rng, budget_distribution)
    else
        budget = -1.
    end
    return budget
end

