"""
Types used in the PMDP
"""
const Action = Float64
const Timestep = Int64

"""
State for the PMDP

States should be used as immutable records
"""
@auto_hash_equals struct State # auto_hash_equals for use of States as keys in Dict in MCTS
    c::Vector{Int64}   # Capacity vector
    t::Timestep               # Timestep
    iₚ::Int64        # Requested product index
end


abstract type PMDP{State,Action} <: MDP{State,Action} end

const EMPTY_PRODUCT_USER_BUDGET = -1.0
const REJECT_ACTION = floatmax()
const ϵ = 10^-12
