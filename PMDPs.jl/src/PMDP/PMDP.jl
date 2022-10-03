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

pp(m::PMDP) = m.pp

products(m::PMDP) = pp(m).P
selling_period_end(m::PMDP) = selling_period_end(pp(m))
budgets(m::PMDP) = pp(m).B
demand(m::PMDP) = pp(m).D
POMDPs.actions(m::PMDP) = pp(m).A
objective(m::PMDP) = pp(m).objective

n_resources(m::PMDP) = n_resources(pp(m))
n_products(m::PMDP) = n_products(pp(m))
n_actions(m::PMDP) = n_actions(pp(m))

empty_product(m::PMDP) = m.empty_product
empty_product_id(m::PMDP) = m.empty_product_id

POMDPs.discount(m::PMDP) = 1.0

productindices(P::Array{Product}) = Dict(zip(P, 1:length(P)))


"""
sale_prob(m::PMDP, s::State, a::Action)

Return the sale probability (Float64) of product requested in state `s` given action `a`
"""
function sale_prob end

"""
sample_customer_budget(m::PMDP, s::State, rng)

Return sampled value (of type Action) of customer budget for product requested in state `s`
"""
function sample_customer_budget end


"""
Returns user buy or no buy decision given agent selected action and user budget.
"""
user_buy(a::Action, budget::Action)::Bool = a <= budget


"""
Returns new vector of resource capacites after sale of product p
"""
# TODO: Could work inplace
reduce_capacities(c::AbstractVector, p::Product) = c .- p

"""
Given state s, determine whether a sale of product s.p is impossible
"""
function sale_impossible(m::PMDP, s::State)::Bool
    p = product(m, s)
    s.iₚ == empty_product_id(m) || any((s.c - p) .< 0.0) || s.t >= selling_period_end(p)
end

function sale_impossible(m::PMDP, s::State, a::Action)::Bool
    a == REJECT_ACTION || sale_impossible(m, s)
end

"""
Given state s, determine whether the state is terminal in the MDP.

State is terminal if it's timestep is over the timestep limit 
or if the capacity of all resources is 0.
"""
function POMDPs.isterminal(m::PMDP, s::State)::Bool
    s.t >= selling_period_end(m) || all(s.c .<= 0)
end

"""
Return an array of actions available in state s. 

If product can be sold in state s, return all actions available in the MDP. 
If not, return only the "impossible" action which is the first elemnt of the action array. 
"""
function POMDPs.actions(m::PMDP, s::State)::AbstractArray{Action}
    actions = POMDPs.actions(m)
    # return sale_impossible(m, s) ? (actions[1],) : actions
    if sale_impossible(m, s)
        return [actions[1]] # TODO - no need for creating new array
    else
        return actions
    end
    return actions
end




"""
Since it may be a bit convoluted to enter rng into sampling 
of demand, the initial state will have no request.
This is the original code:
POMDPs.initialstate(m::PMDP) = Deterministic(State(pp(m).c₀, 1, rand(demand(m)[1])))
The issue was that the rand was independent of rng seeds. 
"""
POMDPs.initialstate(m::PMDP) = Deterministic(State(pp(m).c₀, 1, empty_product_id(m)))


"""
================================================================================
==================== GENERATIVE FUNCTIONS ======================================
================================================================================
"""


"""
Returns the next state from given 
    - state 
    - action 
by sampling the MDP distributions. 
The most important function in the interface used by the search methods.
"""
calculate_reward(pp::PMDPProblem{:revenue}, p::Product, a::Action)= a*sum(p)
calculate_reward(pp::PMDPProblem{:utilization}, p::Product, a::Action)= Float64(sum(p))

function POMDPs.gen(m::PMDP, s::State, a::Action, rng)
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
    # while iₚ==m.empty_product_id && s.t + Δt < selling_period_end(m) 
    #     Δt += 1
    #     iₚ = sample_request(m, s.t+Δt, rng)
    # end
    return (sp = State(c, s.t + Δt, iₚ), r = r, info = (b = b,))
end


# For some reason, the following split of gen into two functions is much slower. 

# function POMDPs.gen_(m::PMDP, s::State, a::Action, rng)
#     r, b, c = sample_reward_and_capacity(m, s, a, rng)
#     Δt = 1
#     iₚ = sample_request(m, s.t + Δt, rng)
#     return (sp = State(c, s.t + Δt, iₚ), r = r, info = (b = b,))
# end

# function sample_reward_and_capacity(m::PMDP, s::State, a::Action, rng)
#     b = sample_customer_budget(m, s, rng)
#     if ~sale_impossible(m, s, a) && user_buy(a, b)
#         r = calculate_reward(pp(m), product(m, s), a)
#         # r = a
#         c = reduce_capacities(s.c, product(m, s))
#     else
#         r = 0.0
#         c = s.c
#     end
#     return (r, b, c)
# end

# function sample_product_and_time_skip_states_with_empty_product(m::PMDP, s::State, rng)
#     Δt::Int64 = 1
#     iₚ = sample_request(m, s.t + Δt, rng)
#     while iₚ==m.empty_product_id && s.t + Δt < selling_period_end(m) 
#         Δt += 1
#         iₚ = sample_request(m, s.t+Δt, rng)
#     end
#     return iₚ, Δt
# end

"""
Returns sampled next requested product id. If in given timestep one of the prodcuts has selling period end,
update the product request probs.

If no product is requested, the index will be higher than the number of products.
"""
@inline function sample_request(m::PMDP, t::Timestep, rng)
    iₚ = rand(rng, demand(m)[t])

    # prod_index == n_products(pp(m))+1 ? p = empty_product(m) : p = products(m)[prod_index]
    # return p
end

"""
Sample user budget Budget for product requested in state s.
"""
function sample_customer_budget(m::PMDP, s::State, rng)::Action
    # local b::Float64
    if s.iₚ != m.empty_product_id
        budget_distribution = budgets(m)[s.iₚ]
        budget = rand(rng, budget_distribution)
    else
        budget = EMPTY_PRODUCT_USER_BUDGET
    end
    return budget
end
