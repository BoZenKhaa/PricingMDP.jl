"""
Structures and functions for the GENERATIVE POMDPs.jl interface of the Pricing MDP
"""

"""
m = PMDPg(edges, products, λ)

PMDP for generative interface
"""
struct PMDPg <: PMDP{State, Action}
    pp::PMDPProblem
    n_res::Int64
    # T::Timestep                  # max timestep
    # E::Array{Edge}
    # P::Array{Product}
    # λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    # selling_period_ends::Array{Timestep} # Selling period end for each product
    empty_product::Product
    # B::Array{Distribution} # User budgets
    # actions::Array{Action}
    # objective::Symbol
    productindices::Dict
    
    function PMDPg(pp)
        empty_product = Product(falses(length(pp.C)), selling_period_end(pp))
        new(pp, length(pp.C), empty_product)
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
    d_demand_model = product_request_dist(t, m.λ, selling_period_ends(m))
    prod_index = rand(rng, d_demand_model)
    return products(m)[prod_index]
end

"""
Sample user budget Budget for product requested in state s.
"""
function sample_customer_budget(m::PMDPg, s::State, rng::AbstractRNG)::Action
    # local b::Float64
    if s.p != empty_product(m)
        budget_distribution = m.B[index(m, s.p)]
        budget = rand(rng, budget_distribution)
    else
        budget = -1.
    end
    return budget
end

