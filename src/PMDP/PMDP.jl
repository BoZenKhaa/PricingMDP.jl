"""
Common definitions for the Pricing MDP
"""

const Product{n_edges} = SVector{n_edges,Bool}
const Action = Float64
const Timestep = Int64

struct Edge
    id::Int64
    c_init::Int64               # initial capacity
    selling_period_end::Timestep  
end

struct State{n_edges}
    c::SVector{n_edges,Int64}   # Capacity vector
    t::Timestep                 # Timestep
    p::Product{n_edges}         # Requested product
end


abstract type UserBudget end

abstract type PMDP{State, Action} <: MDP{State, Action} end

function State(c::Array, t::Timestep, product::Array)
    size = length(c)
    State{size}(SVector{size}(c), t, SVector{size}(product))
end

function show(io::IO, s::State)
    print(io, "c:$(s.c)_t:$(s.t)_p:$(s.p)")
end

"""
Given state s, determine whether a sale of product s.p is impossible
"""
function sale_impossible(m::PMDP, s::State)::Bool
    sale_impossible(m, s.c, s.p)
end

function sale_impossible(m::PMDP, c, p::Product)
    all(c .== 0) || p==m.empty_product || any((c - p) .<0.)
end

"""
    sale_prob(m::PMDP, s::State, a::Action)

Return the sale probability of product requested in state `s` given action `a`
"""
function sale_prob end 

"""
    sample_customer_budget(m::PMDP, s::State, rng::AbstractRNG)

Return sampled value of customer budget for product requested in state `s`
"""
function sample_customer_budget end

function POMDPs.isterminal(m::PMDP, s::State)
    if s.t >= m.T || all(s.c .<= 0) 
        return true
    else
        return false
    end
end

function POMDPs.discount(m::PMDP)
    return 0.99
end

# reduce action set when no product is requested
function POMDPs.actions(m::PMDP, s::State)
    actions = POMDPs.actions(m)
    if sale_impossible(m, s)
        return [actions[1]]
    else
        return actions
    end
    return actions
end

POMDPs.actions(m::PMDP) = m.actions

function POMDPs.initialstate(m::PMDP) 
    Deterministic(State{m.n_edges}(SVector([e.c_init for e in m.E]...), 0, m.empty_product))
end

"""
Returns user buy or no buy decision given agent selected action and user budget.
Probability is based linear in the size of the product, i.e. based on the unit price.
"""
function user_buy(a::Action, budget::Float64)
    a<=budget
end


"""
Given an array of graph edges and products, return a selling period end for each product. 
"""
function get_product_selling_period_ends(E::Array{Edge}, P::Array{Product{n_edges}}) where n_edges
    selling_period_ends = zeros(Int64, length(P))
    for i in 2:length(P)
        prod = P[i]
        selling_period_ends[i] = minimum([e.selling_period_end for e in E[prod]])
    end
    selling_period_ends[1] = maximum(selling_period_ends[2:end])
    return selling_period_ends
end