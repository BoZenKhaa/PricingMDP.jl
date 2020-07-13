module PricingMDPv1

export PMDPv1, State

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions

"""
    pwl(10, slope_start=5., slope_end=30.)

PieceWise Linear "step" function with slope in the middle, like so:
  1-|-----\\
    |      \\
    |       \\
  0-|-----|--\\------
    0  start end

TODO: Handle better configuration of user model in problem, now its hardcoded here.
"""
function pwl(x::Number;
            slope_start::Float64=5.,
            slope_end::Float64=30.)
    if x<slope_start
        return 1.
    elseif x>slope_end
        return 0.
    else
        return (x-slope_end)/(slope_start-slope_end)
    end
end

const n_edges = 3
const products = [SA[0,0,0],SA[1,0,0], SA[0,1,0], SA[0,0,1], SA[1,1,0], SA[0,1,1], SA[1,1,1]]

Product = SVector{n_edges,Bool}
Action = Float64
Timestep = Int64


"""
Returns nothing if p not in products
"""
function prod2ind(p::Product)
    return indexin([p], products)[1]
end

function ind2prod(i::Int64)
    return products[i]
end

struct State
    c::SVector{n_edges,Int64}   # Capacity vector
    t::Timestep                 # Timestep
    p::Product    # Requested product
end

struct PMDPv1 <: MDP{State, Float64}
    T::Timestep                  # max timestep
    # selling_period_end::SVector{n_edges,Int64}
end

function user_buy(p::Product, a::Action, t::Timestep, rng::AbstractRNG)
    if p != SA[0,0,0]
        d_user_buy = Categorical([pwl(a), 1-pwl(a)])
        buy = rand(rng, d_user_buy)==1
    else
        buy = false
    end
    return buy
end

function next_demand(m::PMDPv1, t::Timestep, rng::AbstractRNG)
    if t <= m.T
        d_demand_model = Categorical([0.4,0.1,0.1,0.1,0.1,0.1,0.1])
        prod_index = rand(rng, d_demand_model)
        p = ind2prod(prod_index)
    else
        p = SA[0,0,0]
    end
    return p
end


function POMDPs.gen(m::PMDPv1, s, a, rng)
    if user_buy(s.p, a, s.t, rng)
        r = a
        c = s.c-s.p
    else
        r = 0
        c = s.c
    end
    p = next_demand(m, s.t, rng)
    return (sp = State(c, s.t+1, p), r = r)
end

# function POMDPs.gen(m::PMDPv1, s, a, rng)
#     d_demand_model = Categorical([m.p_customer_arrival,1-m.p_customer_arrival])
#     d_user_model = Categorical([m.p_purchase,1-m.p_purchase])
#
#     if s.t>m.T || s.c==0
#         sp = State(s.t, s.c)
#         r = 0
#     else
#         if rand(rng, d_demand_model)==1 # Customer arrives
#             if rand(rng, d_demand_model)==1 # Customer buys
#                 sp = State(s.t+1, s.c-1)
#                 r = a
#             else # Customer does not buy
#                 sp = State(s.t+1, s.c)
#                 r = 0
#             end
#         else # No user arrives
#             sp = State(s.t+1, s.c)
#             r=0
#         end
#     end
#     return (sp=sp, r=r)
# end

function POMDPs.discount(m::PMDPv1)
    return 0.99
end

POMDPs.actions(m::PMDPv1) = (0.,5.,10.,15.,20.,25.,30.,35.,70.)

POMDPs.initialstate_distribution(m::PMDPv1) = Deterministic(State(SA[4,4,4], 0, nothing))

# PMDPv1() = PMDPv1(30)

end
