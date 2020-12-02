"""
Common definitions for the Pricing MDP
"""


# TODO: maybe? expand Product to contain id selling period end, ... 
const Product{n_edges} = SVector{n_edges,Bool}
const Action = Float64
const Timestep = Int64

# struct Product{n_edges}
#     id::Int64
#     edges::SVector{n_edges,Bool}
#     selling_period_end::Timestep
# end

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


abstract type AbstractUserBudget end

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
    s.p==empty_product(m) || any((s.c - s.p) .<0.) ||  s.t >= selling_period_end(m, s.p)
end

"""
    sale_prob(m::PMDP, s::State, a::Action)

Return the sale probability of product requested in state `s` given action `a`
"""
function sale_prob end

function objective(m::PMDP)
    m.objective
end

n_edges(m::PMDP) = m.n_edges
edges(m::PMDP) = m.E
empty_product(m::PMDP) = m.P[1]
timestep_limit(m::PMDP) = m.T
selling_period_ends(m::PMDP) = m.selling_period_ends
index(m::PMDP, p::Product) = m.productindices[p]
selling_period_end(m::PMDP, p::Product) = selling_period_ends(m)[index(m, p)]
POMDPs.actions(m::PMDP) = m.actions

"""
    sample_customer_budget(m::PMDP, s::State, rng::AbstractRNG)

Return sampled value of customer budget for product requested in state `s`
"""
function sample_customer_budget end

function POMDPs.isterminal(m::PMDP, s::State)
    if s.t >= timestep_limit(m) || all(s.c .<= 0) 
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



function productindices(P::Array{Product{n_edges}} where n_edges)
    Dict(zip(P, 1:length(P)))
end


function POMDPs.initialstate(m::PMDP)
    Deterministic(State{n_edges(m)}(SVector([e.c_init for e in edges(m)]...), 0, empty_product(m)))
end

"""
Returns user buy or no buy decision given agent selected action and user budget.
Probability is based linear in the size of the product, i.e. based on the unit price.
"""
function user_buy(a::Action, budget::Float64)
    a<=budget
end

# TODO: Could work inplace
function reduce_capacities(c::SVector, p::Product)
    c .- p 
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


"""
Get product arrival probablities from homogenous Pois. proc. intensities λ, 
while considering the product selling periods.

Given λ, the expected number of request in period (0,1), 
the probability of request arrivel in given timestep is given by λ~mp where m is the number of timesteps in period (0,1).
"""
function calculate_product_request_probs(t::Timestep,  λ::Array{Float64}, selling_period_ends::Array{Timestep})
    product_request_probs = Array{Float64, 1}(undef, length(λ))
    for i in 2:length(λ)
        if t>selling_period_ends[i]
            product_request_probs[i]=0
        else
            product_request_probs[i]=λ[i]/selling_period_ends[i]
        end
    end
    product_request_probs[1] = 1.0-sum(product_request_probs[2:end])
    @assert 0. <= product_request_probs[1] <= 1. "The non-empty product request probabilities sum is > 1, finer time discretization needed."
    return product_request_probs
end


"""
Returns the next state from given 
    - state 
    - action 
by sampling the MDP distributions. 
The most important function in the interface used by the search methods.
"""
function POMDPs.gen(m::PMDP, s::State, a::Action, rng::AbstractRNG)
    b = sample_customer_budget(m, s, rng)
    if ~sale_impossible(m, s) && user_buy(a, b)
        if objective(m) == :revenue
            r=a
        elseif objective(m) == :utilization
            r=sum(s.p)
        else
            throw(ArgumentError(string("Unknown objective: ", objective(m))))
        end
        # r = a
        c = reduce_capacities(s.c, s.p)
    else
        r = 0.
        c = s.c
    end
    Δt = 1
    prod = sample_request(m, s.t+Δt, rng)
    while sum(prod)==0 && s.t + Δt < timestep_limit(m)  #Empty product
        Δt += 1
        prod = sample_request(m, s.t+Δt, rng)
    end
    return (sp = State(c, s.t+Δt, prod), r = r, info=b)
end

