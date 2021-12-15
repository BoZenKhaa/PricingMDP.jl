"""
Types used in the PMDP
"""
const Action = Float64
const Timestep = Int64

"""
State for the PMDP
"""
struct State{n_res}
    c::SVector{n_res,Int64}   # Capacity vector
    t::Timestep               # Timestep
    iₚ::Int64        # Requested product index
end

abstract type PMDP{State,Action} <: MDP{State,Action} end

const EMPTY_PRODUCT_USER_BUDGET = -1.0
const REJECT_ACTION = floatmax()
const ϵ = 10^-12
