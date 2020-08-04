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
    t::Timestep                # Timestep
    p::Product{n_edges}    # Requested product
end

function show(io::IO, s::State)
    println(io, "t:$(s.t)_c:$(s.c)_p:$(s.p)")
end


"""
m = PMDP(edges, products, λ)
"""
struct PMDP <: MDP{State, Action}
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product{n_edges}} where n_edges
    λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    selling_period_ends::Array{Timestep} # Selling period end for each product
    product_request_probs::Array{Float64} # probability of request arriving in timestep (homogenous Poisson process)
    
    function PMDP(E, P, λ)
        selling_period_ends = get_selling_period_ends(E, P)
        T = selling_period_ends[1]
        product_request_probs = zeros(Float64, length(P))
        set_product_request_probs!(product_request_probs, 0, λ, selling_period_ends)
        return new(T,E,P,λ, selling_period_ends, product_request_probs)
    end
end


# --------------------------------------- Generative interface
"""
Returns next requested product. If in given timestep one of the prodcuts has selling period end, update the product request probs.
"""
function sample_next_request_and_update_probs(m::PMDP, t::Timestep, rng::AbstractRNG)
    if t in m.selling_period_ends
        set_product_request_probs!(m.product_request_probs, t, m.λ, m.selling_period_ends)
    end

    d_demand_model = Categorical(m.product_request_probs)
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
    while sum(prod)==0
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
    if sum(s.p)<=0
        return actions[1]
    else
        return actions
    end
end

POMDPs.actions(m::PMDP) = Float64[0:5:100;] # TODO - fix to take values ftom actions above

#TODO fix for changing initial state for other dims
POMDPs.initialstate_distribution(m::PMDP) = Deterministic(State{5}(SA[5,5,5,5,5], 0, SA[0,0,0,0,0]))



# ------------------------------------- Explicit interface (Methods for VI) --------------------
# @requirements_info SparseValueIterationSolver() mdp

function POMDPs.transition(m::PMDP, s::State, a::Action)
    return SparseCat([s], [1.])
end


function POMDPs.reward(m::PMDP, s::State, a::Action, sp::State)
    if s.c==sp.c
        return 0
    else
        return a
    end
end

function POMDPs.stateindex(m::PMDP, s::State)
    ind = findfirst(isequal(s), states(m))
    if ind==nothing
        println(s, ind)
    end
    return ind
    #TODO: Check this one out https://discourse.julialang.org/t/how-to-convert-cartesianindex-n-values-to-int64/15074/5
end

function POMDPs.actionindex(m::PMDP, a::Action)
    ind = findfirst(isequal(a), actions(m))
    if ind==nothing
        println(a, ind)
    end
    return ind
end

function POMDPs.states(m::PMDP)
    c_it = Iterators.product([0:e.c_init for e in m.E]...)
    s_it = Iterators.product(c_it, 0:maximum(m.selling_period_ends), m.P)
    states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
end

    


