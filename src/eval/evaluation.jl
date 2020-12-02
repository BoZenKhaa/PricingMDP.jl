using POMDPSimulators
using POMDPPolicies
using DataFrames


"""
Run policy on a history loaded in HistoryReplayer and return a new history
"""
function replay(hrpl::HistoryReplayer, policy::Policy, rng::AbstractRNG)::AbstractSimHistory
    
    hrec = HistoryRecorder(max_steps = timestep_limit(hrpl), rng = rng) 
    h = simulate(hrec, hrpl, policy)

    return h
end

"""
Get NamedTuple of metrics (revenue, utilization, number of sold products) of a SimHistory
"""
function get_metrics(h::AbstractSimHistory)::NamedTuple
    revenue = sum(h[:r])
    sold_products = [e.s.p for e in h if e.r>0]
    n_sales = length(sold_products)
    utilization = sum(sum(sold_products))
    (r = revenue, u = utilization, n = n_sales)
end


"""
Return DataFrame of evaluation metrics from running given policies on a given history of requests.

In addition to the metrics, save the name of the policy, hash of the request sequence and seed used in the replay. 
"""
function eval(m::PMDP, requests::AbstractSimHistory, policies::NamedTuple, 
              rng::AbstractRNG)::DataFrame
    hrpl = HistoryReplayer(m, requests)

    metrics = DataFrame()

    for (name, policy) in pairs(policies)
        h = replay(hrpl, policy, rng)
        m = get_metrics(h)
        push!(metrics, (m..., name=name, sequence=hash(requests), replay_rng_seed=rng.seed))
    end
    return metrics
end


"""
Return DataFrame of evaluation metrics of given tuple of policies on a sequence of request sequences. 
"""
function eval(mdp::PMDP, request_sequences::Array{<:AbstractSimHistory}, 
              policies::NamedTuple, rng::AbstractRNG)::DataFrame
    metrics = DataFrame()
    for sequence in request_sequences
        mₛ = eval(mdp, sequence, policies, rng)
        metrics = vcat(metrics, mₛ)
    end
    return metrics
end