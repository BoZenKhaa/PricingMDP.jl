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
"""
function sample_next_request_and_update_probs(m::PMDPg, t::Timestep, rng::AbstractRNG)
    product_request_probs = calculate_product_request_probs(t, m.λ, m.selling_period_ends)
    d_demand_model = Categorical(product_request_probs)
    prod_index = rand(rng, d_demand_model)
    return m.P[prod_index]
end

"""
Returns the next state from given 
    - state 
    - action 
by sampling the MDP distributions. 
The most important function in the interface used by the search methods.
"""
function POMDPs.gen(m::PMDPg, s::State, a::Action, rng::AbstractRNG)
    b = sample_customer_budget(m, s, rng)
    if ~sale_impossible(m, s) && user_buy(a, b)
        if m.objective == :revenue
            r=a
        elseif m.objective == :utilization
            r=sum(s.p)
        else
             throw(ArgumentError(string("Unknown objective: ", m.objective)))
        end
        # r = a
        c = reduce_capacities(s.c, s.p)
    else
        r = 0.
        c = s.c
    end
    prod = sample_next_request_and_update_probs(m, s.t, rng)
    Δt = 1
    while sum(prod)==0 #Empty product
        prod = sample_next_request_and_update_probs(m, s.t, rng)
        Δt += 1
    end
    return (sp = State(c, s.t+Δt, prod), r = r, info=b)
end

"""
Returns the next state from given 
 - state, 
 - action, 
 - request user budget.
This method is only useful for evaluation on existing set of customer requests.
"""

