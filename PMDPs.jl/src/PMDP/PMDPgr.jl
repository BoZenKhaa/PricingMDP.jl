"""
Structures and functions for the GENERATIVE POMDPs.jl interface for use in FAST ROLLOUTS (skipping uneventful states).
"""

"""
m = PMDPgr(edges, products, λ)

PMDP for generative interface with rollouts using skips. 

The fields are the same as PMDPg.
"""
struct PMDPgr <: PMDP{State,Action}
    pp::PMDPProblem                # Pricing Problem
    empty_product::Product
    empty_product_id::Int64

    # function PMDPgr(pp::PMDPProblem)
    #     new(pp, empty_product(pp), n_products(pp) + 1)
    # end

    function PMDPgr(mdp::PMDPg)
        new(mdp.pp, mdp.empty_product, mdp.empty_product_id)
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

function POMDPs.gen(m::PMDPgr, s::State, a::Action, rng)
    b = sample_customer_budget(m, s, rng)
    if ~sale_impossible(m, s, a) && user_buy(a, b)
        r = calculate_reward(pp(m), product(m, s), a)
        c = reduce_capacities(s.c, product(m, s))
    else
        r = 0.0
        c = s.c
    end
    Δt = 1
    iₚ = sample_request(m, s.t + Δt, rng)
    # Following code causes skips into the future. 
    while iₚ==m.empty_product_id && s.t + Δt < selling_period_end(m) 
        Δt += 1
        iₚ = sample_request(m, s.t+Δt, rng)
    end
    return (sp = State(c, s.t + Δt, iₚ), r = r, info = (b = b,))
end