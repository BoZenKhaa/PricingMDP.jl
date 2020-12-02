using POMDPSimulators
using POMDPPolicies
using DataFrames

function replay(hrpl::HistoryReplayer, policy::Policy, rng::AbstractRNG)::AbstractSimHistory
    
    hrec = HistoryRecorder(max_steps = timestep_limit(hrpl), rng = rng) 
    h = simulate(hrec, hrpl, policy)

    return h
end

function get_metrics(h::AbstractSimHistory)::NamedTuple
    revenue = sum(h[:r])
    sold_products = [e.s.p for e in h if e.r>0]
    n_sales = length(sold_products)
    utilization = sum(sum(sold_products))
    (r = revenue, u = utilization, n = n_sales)
end

function eval(m::PMDP, requests::AbstractSimHistory, policies::NamedTuple, 
              rng::AbstractRNG)
    hrpl = HistoryReplayer(m, requests)

    metrics = DataFrame()

    for (name, policy) in pairs(policies)
        h = replay(hrpl, policy, rng)
        m = get_metrics(h)
        push!(metrics, (m..., name=name, sequence=hash(requests), replay_rng_seed=rng.seed))
    end
    return metrics
end

function eval(mdp::PMDP, request_sequences::Array{<:AbstractSimHistory}, 
              policies::NamedTuple, rng::AbstractRNG)
    metrics = DataFrame()
    for sequence in request_sequences
        mₛ = eval(mdp, sequence, policies, rng)
        metrics = vcat(metrics, mₛ)
    end
    return metrics
end