using StaticArrays

"""
Get flatrate policy that optimizes the objective across a set of training histories
"""

"""
Returns lists of possible revenues and utilizations indexed by actions.

Used to select the best flatrate.
"""
function flatrate_analysis(mdp::PMDP, h::AbstractSimHistory)
    # extract request trace from history
    trace = collect(eachstep(h, "s, info"))
    requests = [rec for rec in trace if rec.s.iₚ !=PMDPs.empty_product_id(mdp)]

    # get data from trace
    request_edges = [[PMDPs.product(mdp, rec.s)...] for rec in requests]
    request_budgets = [rec.info.b for rec in requests]

    # Chech revenue of each flatrate
    r_as = PMDPs.Action[] # array containing total revenue for each possible flatrat
    u_as = Int64[] # array of final capacity for each flatrate
    for flatrate in POMDPs.actions(mdp)
        c_init = PMDPs.problem(mdp).c₀
        c = copy(c_init)
        r_a = 0.
        for i in 1:length(requests)
            if ~PMDPs.sale_impossible(mdp, requests[i].s) && PMDPs.user_buy(flatrate, request_budgets[i])
                c = PMDPs.reduce_capacities(c, product(mdp, requests[i].s))
                r_a +=flatrate
            end
        end
        push!(r_as, r_a)
        push!(u_as, sum(c_init - c))
    end

    return (r_a = r_as, u_a = u_as)
end

function optimize_flatrate_policy(mdp::PMDP, training_histories::AbstractArray{<:AbstractSimHistory})::Tuple

    # row index labels are mdp actions, column index labels are training histories
    R = []
    U = []
    for h in training_histories
        r_as, u_as = flatrate_analysis(mdp, h)
        push!(R, r_as)
        push!(U, u_as)
    end

    return hcat(R...), hcat(U...)
end

"""
Get flatrate policy from a training set of histories
"""
function get_flatrate_policy(mdp::PMDP, training_histories::Array{<:AbstractSimHistory}; objective=:revenue)::Policy
    R, U = optimize_flatrate_policy(mdp, training_histories)
    
    if objective==:revenue
        M = R
    elseif objective==:utilization
        M = U
    end

    best_results = sum(M; dims=2)
    best_flatrate = POMDPs.actions(mdp)[findmax(best_results)[2]]
    
    FunctionPolicy(s->best_flatrate)
end