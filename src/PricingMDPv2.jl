const Product{n_edges} = SVector{n_edges,Bool}
const Action = Float64
const Timestep = Int64

# struct ProductIndexed
#     p::SVector{n_edges,Bool} where n_edges
#     id::Int64
# end

struct Edge
    id::Int64
    c_init::Int64                    # initial capacity
    selling_period_end::Timestep  
end

struct State{n_edges}
    c::SVector{n_edges,Int64}   # Capacity vector
    t::Timestep                 # Timestep
    p::Product{n_edges}         # Requested product
end

abstract type UserBudget end

struct BudgetPerUnit <: UserBudget
    β::Distribution
end

function State(c::Array, t::Timestep, product::Array)
    size = length(c)
    State{size}(SVector{size}(c), t, SVector{size}(product))
end

function show(io::IO, s::State)
    print(io, "c:$(s.c)_t:$(s.t)_p:$(s.p)")
end

"""
Enumerates all states for MDP
"""
function generate_states(E, P, selling_period_ends)
    c_it = Iterators.product([0:e.c_init for e in E]...)
    s_it = Iterators.product(c_it, 0:maximum(selling_period_ends), P)
    states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
end

abstract type PMDP{State, Action} <: MDP{State, Action} end


function stateindices(E::Array{Edge}, T::Timestep, P::Array{Product{N}, 1} where N)
    C_sizes = [e.c_init+1 for e in E]
    T_size = T+1
    prd_sizes = length(P)

    LinearIndices((C_sizes..., T_size, prd_sizes))
end

function productindices(P::Array{Product{n_edges}} where n_edges)
    Dict(zip(P, 1:length(P)))
end


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
    B::UserBudget # User budgets
    actions::Array{Action}
    objective::Symbol
    # states::Array{State} # ONLY USEFUL FOR EXPLICIT
    
    function PMDPg(E, P, λ, B, A, objective)
        selling_period_ends = get_selling_period_ends(E, P)
        T = selling_period_ends[1]
        empty_product=P[1]
        # states = generate_states(E, P, selling_period_ends)
        @assert objective in [:revenue, :utilization]
        # sli = stateindices(E, T, P)
        return new(length(E), T,E,P,λ, selling_period_ends, empty_product,B, A, objective)
    end
end

"""
m = PMDPe(edges, products, λ)

PMDP for explicit interface
"""
struct PMDPe <: PMDP{State, Action}
    n_edges::Int64
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product}
    λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    selling_period_ends::Array{Timestep} # Selling period end for each product
    empty_product::Product
    actions::Array{Action}
    B::UserBudget # User budgets
    objective::Symbol
    statelinearindices::LinearIndices # ONLY FOR EXPLICIT, replaces need for states array
    productindices::Dict
    # states::Array{State} # ONLY USEFUL FOR EXPLICIT
    
    function PMDPe(E, P, λ, B, A, objective)
        selling_period_ends = get_selling_period_ends(E, P)
        T = selling_period_ends[1]
        empty_product=P[1]
        @assert objective in [:revenue, :utilization]
        # states = generate_states(E, P, selling_period_ends)
        sli = stateindices(E, T, P)
        pi = productindices(P)
        return new(length(E), T,E,P,λ, selling_period_ends, empty_product, A, B, objective, sli, pi)
    end
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
 
# -------------------------- Generative interface --------------------------

"""
Returns next requested product. If in given timestep one of the prodcuts has selling period end, update the product request probs.
"""
function sample_next_request_and_update_probs(m::PMDP, t::Timestep, rng::AbstractRNG)
    product_request_probs = calculate_product_request_probs(t, m.λ, m.selling_period_ends)
    d_demand_model = Categorical(product_request_probs)
    prod_index = rand(rng, d_demand_model)
    return ind2prod(prod_index, m.P)
end

function POMDPs.gen(m::PMDPg, s::State, a::Action, rng::AbstractRNG)
    b = sample_user_budget_linear(m, m.B, s.p, s.t, rng)
    if ~sale_impossible(m, s) && user_buy(a, b)
        if m.objective == :revenue
            r=a
        elseif m.objective == :utilization
            r=sum(s.p)
        else
             throw(ArgumentError(string("Unknown objective: ", m.objective)))
        end
        # r = a
        c = s.c-s.p
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



# --------------------------- Explicit interface (Methods for VI) --------------------
# @requirements_info SparseValueIterationSolver() mdp

function POMDPs.transition(m::PMDPe, s::State, a::Action)
    # if s.t>=m.T
        # sps = [s]
        # probs = [1.]
    # else # t<T
        # --- Request arrival probs
        product_request_probs = calculate_product_request_probs(s.t, m.λ, m.selling_period_ends)
        
        # NEXT STATES
        # No sale due to no request or due to insufficient capacity
        if  sale_impossible(m, s) 
            sps = [State(s.c, s.t+1, prod) for prod in m.P]
            probs = product_request_probs
            # transitions = SparseCat(sps, probs)
        else
            prob_sale = get_sale_prob(m.B, s, a)

            # sufficient capacity for sale and non-empty request
            sps_nosale = [State(s.c, s.t+1, prod) for prod in m.P]
            probs_nosale = product_request_probs.*(1-prob_sale)

            sps_sale = [State(s.c-s.p, s.t+1, prod) for prod in m.P]
            probs_sale = product_request_probs.*prob_sale

            sps = vcat(sps_nosale, sps_sale)
            probs = vcat(probs_nosale, probs_sale)
        end
    # end

    @assert sum(probs) ≈ 1.
    
    return SparseCat(sps, probs)
end

function POMDPs.reward(m::PMDPe, s::State, a::Action, sp::State)
    if m.objective == :revenue
        s.c==sp.c ? 0. :  a
    elseif m.objective == :utilization
        s.c==sp.c ? 0. :  sum(s.p)
    end
end

index(m::PMDPe, p::Product) = m.productindices[p]

function POMDPs.stateindex(m::PMDPe, s::State)
    ci = CartesianIndex((s.c.+1)..., s.t+1, index(m, s.p))
    m.statelinearindices[ci]
end

function POMDPs.actionindex(m::PMDPe, a::Action)
    # ind = 
    return findfirst(isequal(a), actions(m))
    # if ind===nothing
    #     println(a, ind)
    # end
    # return ind
end

function POMDPs.states(m::PMDPe)
    generate_states(m.E, m.P, m.selling_period_ends)
    # m.states
end

# function POMDPs.states(m::PMDP)
#     c_it = Iterators.product([0:e.c_init for e in m.E]...)
#     s_it = Iterators.product(c_it, 0:maximum(m.selling_period_ends), m.P)
#     states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
# end