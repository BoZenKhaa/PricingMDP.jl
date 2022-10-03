"""
HistoryReplayer uses the generative PMDP interface to replay requests in history h.

Usage: 


"""
struct HistoryReplayer <: PMDP{State,Action}
    pp::PMDPProblem
    empty_product::Product
    empty_product_id::Int64
    h::AbstractVector{<:NamedTuple}
    request_timesteps::Array{Int64}

    function HistoryReplayer(m::PMDP, h::AbstractVector{<:NamedTuple})
        return new(
            m.pp,
            empty_product(m),
            empty_product_id(m),
            h,
            collect([s.t for s in h[:s]]),
        )
    end
end

POMDPs.initialstate(hr::HistoryReplayer) = Deterministic(hr.h[1].s)

"""
Returns next requested product. If in given timestep one of the prodcuts has selling period end, update the product request probs.
"""
function sample_request(hr::HistoryReplayer, t::Timestep, rng)::Int64
    history_index = findfirst(x -> x == t, hr.request_timesteps)
    if history_index === nothing
        iₚ = empty_product_id(hr)
    else
        iₚ = hr.h[history_index].s.iₚ
    end
    return iₚ
end

"""
Sample user budget Budget for product requested in state s.
"""
function sample_customer_budget(hr::HistoryReplayer, s::State, rng)::Action
    history_index = findfirst(x -> x == s.t, hr.request_timesteps)
    if history_index === nothing
        budget = EMPTY_PRODUCT_USER_BUDGET
    else
        budget = hr.h[history_index].info.b
    end
    return budget
end
