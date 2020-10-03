function flatrate_pricing(mdp::PMDP, h::SimHistory)
    # extract request trace from history
    trace = collect(eachstep(h, "s, info"))
    requests = [rec for rec in trace if rec.s.p!=mdp.empty_product]

    # get data from trace
    request_edges = [[rec.s.p...] for rec in requests]
    request_budgets = [rec.info for rec in requests]

    # Chech revenue of each flatrate
    r_max = 0
    r_as = []
    for a in mdp.actions
        c = [e.c_init for e in mdp.E]
        r_a = 0
        for i in 1:length(requests)
            if ~PricingMDP.sale_impossible(mdp, c, requests[i].s.p) && a < request_budgets[i]
                c -= requests[i].s.p
                r_a +=a
            end
        end
        push!(r_as, r_a)
        r_a>r_max ? r_max=r_a : r_max
    end
    return (r = r_max, r_a = r_as)
end