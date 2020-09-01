const Product{n_edges} = SVector{n_edges,Bool}
const Action = Float64
const Timestep = Int64

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

function State(c::Array, t::Timestep, product::Array)
    size = length(c)
    State{size}(SVector{size}(c), t, SVector{size}(product))
end

function show(io::IO, s::State)
    println(io, "c:$(s.c)_t:$(s.t)_p:$(s.p)")
end

"""
Enumerates all states for MDP
"""
function generate_states(E, P, selling_period_ends)
    c_it = Iterators.product([0:e.c_init for e in E]...)
    s_it = Iterators.product(c_it, 0:maximum(selling_period_ends), P)
    states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
end

"""
m = PMDP(edges, products, λ)
"""
struct PMDP <: MDP{State, Action}
    n_edges::Int64
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product}
    λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    selling_period_ends::Array{Timestep} # Selling period end for each product
    empty_product::Product
    states::Array{State} # ONLY USEFUL FOR EXPLICIT
    # product_request_probs::Array{Float64} # probability of request arriving in timestep (homogenous Poisson process)
    
    function PMDP(E, P, λ)
        selling_period_ends = get_selling_period_ends(E, P)
        T = selling_period_ends[1]
        empty_product=P[1]
        states = generate_states(E, P, selling_period_ends)
        # product_request_probs = zeros(Float64, length(P))
        # set_product_request_probs!(product_request_probs, 0, λ, selling_period_ends)
        return new(length(empty_product), T,E,P,λ, selling_period_ends, empty_product, states)
    end
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

function POMDPs.gen(m::PMDP, s::State, a::Action, rng::AbstractRNG)
    if user_buy(m, s.p, a, s.t, rng)
        r = a
        c = s.c-s.p
    else
        r = 0
        c = s.c
    end
    prod = sample_next_request_and_update_probs(m, s.t, rng)
    Δt = 1
    while sum(prod)==0 #Empty product
        prod = sample_next_request_and_update_probs(m, s.t, rng)
        Δt += 1
    end
    return (sp = State(c, s.t+Δt, prod), r = r)
end

function POMDPs.isterminal(m::PMDP, s::State)
    if s.t>m.T || sum(s.c.<=0)>0 
        return true
    else
        return false
    end
end

function POMDPs.discount(m::PMDP)
    return 0.99
end


function POMDPs.actions(m::PMDP, s::State; actions = Action[0:5:100;])
    # if sum(s.p)<=0
    #     return actions[1]
    # else
    #     return actions
    # end
    return actions
end

POMDPs.actions(m::PMDP) = Float64[0:5:100;] # TODO - fix to take values ftom actions above

#TODO fix for changing initial state for other dims
POMDPs.initialstate_distribution(m::PMDP) = Deterministic(State{5}(SA[5,5,5,5,5], 0, SA[0,0,0,0,0]))



# --------------------------- Explicit interface (Methods for VI) --------------------
# @requirements_info SparseValueIterationSolver() mdp

function POMDPs.transition(m::PMDP, s::State, a::Action)
    if s.t>=m.T
        transitions = SparseCat(s, [1.])
    else # t<T
        # PROBS
        # --- Product sale
        if s.p==m.empty_product
            prob_sale = 0.
        else           
            prob_sale = prob_sale_linear(s.p, a)
        end
        # --- Request arrival
        product_request_probs = calculate_product_request_probs(s.t, m.λ, m.selling_period_ends)
        
        # NEXT STATES
        if any(s.c - s.p .<0)
            # insufficent capacity for sale
            sps = [State(s.c, s.t+1, prod) for prod in m.P[2:end]]
            probs = product_request_probs
            transitions = SparseCat(sps, probs)
        else
            # sufficient capacity for sale
            sps_nosale = [State(s.c, s.t+1, prod) for prod in m.P[2:end]]
            sps_nosale_probs = product_request_probs.*(1-prob_sale)

            sps_sale = [State(s.c-s.p, s.t+1, prod) for prod in m.P[2:end]]
            sps_sale_probs = product_request_probs.*prob_sale

            transitions = SparseCat([sps_nosale..., sps_sale...], 
                                    [sps_nosale_probs..., sps_sale_probs...])
        end
    end
    return transitions
end

function POMDPs.reward(m::PMDP, s::State, a::Action, sp::State)
    if s.c==sp.c
        return 0
    else
        return a
    end
end

function POMDPs.stateindex(m::PMDP, s::State)
    S = states(m)
    cart_ind = findfirst(isequal(s), S)

    # ind = 
    LinearIndices(S)[cart_ind]
    # if ind===nothing
    #     println(s, ind)
    # end
    # return ind
end

function POMDPs.actionindex(m::PMDP, a::Action)
    # ind = 
    return findfirst(isequal(a), actions(m))
    # if ind===nothing
    #     println(a, ind)
    # end
    # return ind
end

function POMDPs.states(m::PMDP)
    m.states
end

# function POMDPs.states(m::PMDP)
#     c_it = Iterators.product([0:e.c_init for e in m.E]...)
#     s_it = Iterators.product(c_it, 0:maximum(m.selling_period_ends), m.P)
#     states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
# end