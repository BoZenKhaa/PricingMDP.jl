"""
Definitions of the Pricing MDP

How show this be defined? I see two options:
 - CLASSICAL (Python?) WAY: each PMDP is given given by struct of the same type that is built 
   using helper functions and stores the problem information inside the struct. (<-- What I have right now)
    - (+) I have it already this way
    - (+) I can easily have multiple instances side by side (I can have that with the other one as well)
    - (-) I am already deviating from this in HistoryReplayer, which seems it could have been a lot easier in the second option
 - MULTIPLE DISPATCH WAY: each PMDP instance is its own subtype of PMDP and to 
   define a problem instance, you have to redefine abstract PMDP methods
    - (+) Seems like a natural way to write Julia
    - (+) Better decoupling of logic and instance data
    - (-) if replacing struct field (e.g. λ) with a method, the method cannot be defined by a function call (e.g. λ() = get_λ(arg) ) as that 
    would call the function each time λ() is accessed. This can be addressed by putting stuff into variables and then assigning them to functions.
    - (-) sounds like work to rewrite the code this way

Conclusion: I will give it a go.
"""


"""
Types used in the PMDP
"""
# TODO: maybe? expand Product to contain id selling period end, ... 
# TODO: maybe product should be an array of edges directly, i.e. a dict or something?
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

function State(c::Array, t::Timestep, product::Array)
    size = length(c)
    State{size}(SVector{size}(c), t, SVector{size}(product))
end

function show(io::IO, s::State)
    print(io, "c:$(s.c)_t:$(s.t)_p:$(s.p)")
end

abstract type PMDP{State, Action} <: MDP{State, Action} end

"""
Values needed for defining PMDP instance
 - objective - optimization goal in the PMDP
 - edges - edges of the underlying resource graph
 - products - products are combinations of the resource edges
 - selling_period_ends - 

"""

objective(m::PMDP) = m.objective
n_edges(m::PMDP) = m.n_edges
edges(m::PMDP) = m.E
timestep_limit(m::PMDP) = m.T
selling_period_ends(m::PMDP) = m.selling_period_ends
products(m::PMDP) = m.P
POMDPs.actions(m::PMDP) = m.actions
POMDPs.discount(m::PMDP) = 0.99

index(m::PMDP, p::Product) = m.productindices[p]
empty_product(m::PMDP) = products(m)[1]
selling_period_end(m::PMDP, p::Product) = selling_period_ends(m)[index(m, p)]
# budget()

"""
sale_prob(m::PMDP, s::State, a::Action)

Return the sale probability (Float64) of product requested in state `s` given action `a`
"""
function sale_prob end

"""
sample_customer_budget(m::PMDP, s::State, rng::AbstractRNG)

Return sampled value (of type Action) of customer budget for product requested in state `s`
"""
function sample_customer_budget end

"""
Returns user buy or no buy decision given agent selected action and user budget.
"""
user_buy(a::Action, budget::Action)::Bool = a<=budget

# TODO: Could work inplace
reduce_capacities(c::SVector, p::Product) = c .- p

"""
Given state s, determine whether a sale of product s.p is impossible
"""
function sale_impossible(m::PMDP, s::State)::Bool
    s.p==empty_product(m) || any((s.c - s.p) .<0.) ||  s.t >= selling_period_end(m, s.p)
end

"""
Given state s, determine whether the state is terminal in the MDP.

State is terminal if it's timestep is over the timestep limit 
or if the capacity of all resources is 0.
"""
function POMDPs.isterminal(m::PMDP, s::State)::Bool
    if s.t >= timestep_limit(m) || all(s.c .<= 0) 
        return true
    else
        return false
    end
end

"""
Return an array of actions available in state s. 

If product can be sold in state s, return all actions available in the MDP. 
If not, return only the "impossible" action which is the first elemnt of the action array. 
"""
function POMDPs.actions(m::PMDP, s::State)::AbstractArray{Action}
    actions = POMDPs.actions(m)
    if sale_impossible(m, s)
        return [actions[1]]
    else
        return actions
    end
    return actions
end

productindices(P::Array{Product{n_edges}} where n_edges) = Dict(zip(P, 1:length(P)))

POMDPs.initialstate(m::PMDP) = Deterministic(State{n_edges(m)}(SVector([e.c_init for e in edges(m)]...), 0, empty_product(m)))


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
function product_request_dist(t::Timestep,  λ::Array{Float64}, selling_period_ends::Array{Timestep})::Distribution
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
    # product_request_probs = calculate_product_request_probs(t, λ, selling_period_ends(m))
    return Categorical(product_request_probs)  
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
    return (sp = State(c, s.t+Δt, prod), r = r, info=(b=b,))
end

