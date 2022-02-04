"""
Structures and functions for the GENERATIVE POMDPs.jl interface of the Pricing MDP
"""

"""
m = PMDPg(edges, products, λ)

PMDP for generative interface
"""
struct PMDPg <: PMDP{State,Action}
    pp::PMDPProblem{Objective} where Objective      # Pricing Problem
    empty_product::Product
    empty_product_id::Int64

    function PMDPg(pp::PMDPProblem)
        empty_prod = empty_product(pp)
        n_prods = n_products(pp) + 1
        new(pp, empty_prod, n_prods)
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

