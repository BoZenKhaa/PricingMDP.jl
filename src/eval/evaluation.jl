using POMDPSimulators
using POMDPPolicies
using DataFrames


"""
Run policy on a history loaded in HistoryReplayer and return a new history
"""
function replay(hrpl::HistoryReplayer, policy::Policy, rng::AbstractRNG)::SimHistory
    
    hrec = HistoryRecorder(max_steps = selling_period_end(hrpl), rng = rng) 
    h = simulate(hrec, hrpl, policy)

    return h
end

"""
Get NamedTuple of metrics:
    :r revenue, 
    :u utilization, 
    :nₛ number of sold products, 
    :nᵣ number of non-empty requests
 for given SimHistory
"""
function get_metrics(m::PMDP, h::AbstractSimHistory)::NamedTuple
    revenue = sum(h[:r])
    sold_product_sizes::Array{Int64,1} = [sum(product(m, e.s)) for e in h if e.s.c!=e.sp.c]
    n_sales = length(sold_product_sizes)
    n_requests = length([e for e in h if e.s.iₚ!=PMDPs.empty_product_id(m)])
    utilization = sum(sold_product_sizes)
    @assert utilization == sum(h[1].s.c - h[end].sp.c) string("utilization ", utilization, " is not ", h[1].s.c, " - ", h[end].sp.c, h)
    (r = revenue, u = utilization, nₛ = n_sales, nᵣ = n_requests)
end


"""
Return DataFrame of evaluation metrics from running given policies on a given history of requests.

In addition to the metrics, save the name of the policy, hash of the request sequence and seed used in the replay. 
"""
function eval(mdp::PMDP, requests::AbstractSimHistory, policies::NamedTuple, 
              rng::AbstractRNG)::DataFrame
    hrpl = HistoryReplayer(mdp, requests)

    metrics = DataFrame()

    for (name, policy) in pairs(policies)
        h = replay(hrpl, policy, rng)
        m = get_metrics(mdp, h)
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