"""
Structures and functions for the GENERATIVE POMDPs.jl interface of the Pricing MDP
"""

"""
m = PMDPg(edges, products, λ)

PMDP for generative interface
"""
struct PMDPg <: PMDP{State,Action}
    pp::PMDPProblem                # Pricing Problem
    empty_product::Product
    empty_product_id::Int64

    function PMDPg(pp::PMDPProblem)
        new(pp, empty_product(pp), n_products(pp) + 1)
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
Returns next requested product. If in given timestep one of the prodcuts has selling period end,
update the product request probs.

If no product is requested, the index will be higher than the number of products.

TODO: Potential speedup if product_request_probs are not recalculated at every step
"""
function sample_request(m::PMDPg, t::Timestep, rng::AbstractRNG)::Int64
    iₚ = rand(rng, demand(m)[t])

    # prod_index == n_products(pp(m))+1 ? p = empty_product(m) : p = products(m)[prod_index]
    # return p
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
        budget = EMPTY_PRODUCT_USER_BUDGET
    end
    return budget
end

