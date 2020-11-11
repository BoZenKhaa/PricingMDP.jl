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
Given state s, determine whether a sale of product s.p is impossible
"""
function sale_impossible(m::PMDP, s::State)::Bool
    sale_impossible(m, s.c, s.p)
end

function sale_impossible(m::PMDP, c, p::Product)
    all(c .== 0) || p==m.empty_product || any((c - p) .<0.)
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

# include("PMDPe.jl")
# include("PMDPg.jl")