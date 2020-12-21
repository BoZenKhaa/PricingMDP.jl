"""
HistoryReplayer uses the generative PMDP interface to reaplay requests in history h.

Usage: 


"""
struct HistoryReplayer<:PMDP{State, Action}
    m::PMDP
    h::AbstractSimHistory
    request_timesteps::Array{Int64}
    
    function HistoryReplayer(m::PMDP, h::AbstractSimHistory)
        return new(m, h, collect([s.t for s in h[:s]]))
    end
end

objective(hr::HistoryReplayer) = objective(hr.m)
n_edges(hr::HistoryReplayer) = n_edges(hr.m)
edges(hr::HistoryReplayer) = edges(hr.m)
empty_product(hr::HistoryReplayer) = empty_product(hr.m)
timestep_limit(hr::HistoryReplayer) = timestep_limit(hr.m)
selling_period_ends(hr::HistoryReplayer) = selling_period_ends(hr.m)
index(hr::HistoryReplayer, p::Product) = index(hr.m, p)
POMDPs.actions(hr::HistoryReplayer) = POMDPs.actions(hr.m)

"""
Returns next requested product. If in given timestep one of the prodcuts has selling period end, update the product request probs.
"""
function sample_request(hr::HistoryReplayer, t::Timestep, rng::AbstractRNG)::Product
    history_index = findfirst(x->x==t, hr.request_timesteps)
    if history_index === nothing
        p = empty_product(hr)
    else
        p = hr.h[history_index].s.p
    end
    return p
end

"""
Sample user budget Budget for product requested in state s.
"""
function sample_customer_budget(hr::HistoryReplayer, s::State, rng::AbstractRNG)::Float64
    history_index = findfirst(x->x==s.t, hr.request_timesteps)
    if history_index === nothing
        budget = -1.
    else
        budget = hr.h[history_index].info.b
    end
    return budget
end