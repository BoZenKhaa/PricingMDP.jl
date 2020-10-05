function flatrate_pricing(mdp::PMDP, h::SimHistory)
    # extract request trace from history
    trace = collect(eachstep(h, "s, info"))
    requests = [rec for rec in trace if rec.s.p!=mdp.empty_product]

    # get data from trace
    request_edges = [[rec.s.p...] for rec in requests]
    request_budgets = [rec.info for rec in requests]

    # Chech revenue of each flatrate
    r_as = [] # array containing total revenue for each possible flatrat
    u_as = [] # array of final capacity for each flatrate
    for flatrate in mdp.actions
        c_init = [e.c_init for e in mdp.E]
        c = copy(c_init)
        r_a = 0
        for i in 1:length(requests)
            if ~PricingMDP.sale_impossible(mdp, c, requests[i].s.p) && flatrate < request_budgets[i]
                c -= requests[i].s.p
                r_a +=flatrate
            end
        end
        push!(r_as, r_a)
        push!(u_as, sum(c_init - c))
    end

    return (r_a = r_as, u_a = u_as)
end