module SimplestPricingMDP

export SPMDP

using POMDPs
using POMDPModelTools
using StaticArrays
using MCTS
using Random, Distributions

struct SPMDP <: MDP{SVector{2,Int64}, Float64}
    r_sale::Float64
    r_no_sale::Float64
    p_customer_arrival::Float64
    p_purchase::Float64
    T::Int64
end

function POMDPs.gen(m::SPMDP, s, a, rng)
    d_demand_model = Categorical([m.p_customer_arrival,1-m.p_customer_arrival])
    d_user_model = Categorical([m.p_purchase,1-m.p_purchase])

    if s[1]>m.T || s[2]==0
        sp = SA[s[1], s[2]]
        r = 0
    else
        if rand(rng, d_demand_model)==1 # Customer arrives
            if rand(rng, d_demand_model)==1 # Customer buys
                sp = SA[s[1]+1, s[2]-1]
                r = a
            else # Customer does not buy
                sp = SA[s[1]+1, s[2]]
                r = 0
            end
        else # No user arrives
            sp = SA[s[1]+1, s[2]]
            r=0
        end
    end
    return (sp=sp, r=r)
end

function POMDPs.discount(m::SPMDP)
    return 0.99
end

POMDPs.actions(m::SPMDP) = (1,2,3)

POMDPs.initialstate_distribution(m::SPMDP) = Deterministic(SA[0, 5])

SPMDP() = SPMDP(1, 0, 0.5, 0.3, 30)
end
