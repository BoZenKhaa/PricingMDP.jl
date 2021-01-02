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
Values needed for defining PMDP instance
 - objective - optimization goal in the PMDP
 - edges - edges of the underlying resource graph
 - products - products are combinations of the resource edges
 - selling_period_ends - 

"""

problem(m::PMDP) = m.pp

products(m::PMDP) = problem(m).P
selling_period_end(m::PMDP) = selling_period_end(problem(m))
budgets(m::PMDP) = problem(m).B
demand(m::PMDP) = problem(m).D
POMDPs.actions(m::PMDP) = problem(m).A
objective(m::PMDP) = problem(m).objective

n_resources(m::PMDP) = n_resources(problem(m))
n_products(m::PMDP) = n_products(problem(m))
n_actions(m::PMDP) = n_actions(problem(m))

empty_product(m::PMDP) = m.empty_product
empty_product_id(m::PMDP) = m.empty_product_id

POMDPs.discount(m::PMDP) = 0.99

index(m::PMDP, p::Product) = m.productindices[p]

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


"""
Returns new vector of resource capacites after sale of product p
"""
# TODO: Could work inplace
reduce_capacities(c::SVector, p::Product) = c .- p

"""
Given state s, determine whether a sale of product s.p is impossible
"""
function sale_impossible(m::PMDP, s::State, a::Action)::Bool
    p = product(m, s)
    a==REJECT_ACTION || s.iₚ==empty_product_id(m) || any((s.c - p) .<0.) ||  s.t >= selling_period_end(p)
end

"""
Given state s, determine whether the state is terminal in the MDP.

State is terminal if it's timestep is over the timestep limit 
or if the capacity of all resources is 0.
"""
function POMDPs.isterminal(m::PMDP, s::State)::Bool
    if s.t >= selling_period_end(m) || all(s.c .<= 0) 
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

productindices(P::Array{Product{n_res}} where n_res) = Dict(zip(P, 1:length(P)))

POMDPs.initialstate(m::PMDP) = Deterministic(State{n_resources(m)}(SVector([e.c_init for e in edges(m)]...), 0, empty_product(m)))

"""
Returns the next state from given 
    - state 
    - action 
by sampling the MDP distributions. 
The most important function in the interface used by the search methods.
"""
function POMDPs.gen(m::PMDP, s::State, a::Action, rng::AbstractRNG)
    b = sample_customer_budget(m, s, rng)
    if ~sale_impossible(m, s, a) && user_buy(a, b)
        if objective(m) == :revenue
            r=a
        elseif objective(m) == :utilization
            r=sum(product(m, s))
        else
            throw(ArgumentError(string("Unknown objective: ", objective(m))))
        end
        # r = a
        c = reduce_capacities(s.c, product(m, s))
    else
        r = 0.
        c = s.c
    end
    Δt = 1
    iₚ = sample_request(m, s.t+Δt, rng)
    while iₚ==m.empty_product_id && s.t + Δt < selling_period_end(m)  #Empty product
        Δt += 1
        iₚ = sample_request(m, s.t+Δt, rng)
    end
    return (sp = State(c, s.t+Δt, iₚ), r = r, info=(b=b,))
end

