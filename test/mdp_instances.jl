function dead_simple_mdps()
    β = DiscreteNonParametric([10.], [1.])

    E = [PricingMDP.Edge(1, 2, 6), # id, c
        PricingMDP.Edge(2, 3, 8)]
    # edge_selling_period_ends = [6,8]
    P = [SA[false, false], 
        SA[true, false], 
        SA[false, true], 
        SA[true, true]]
    λ = [1.,1.,1.,1.]
    B = [β, β, β, β]
    A = [0., 5., 10., 15., 1000.]
    objective = :revenue

    mg = PMDPg(E, P, λ, B, A, objective)
    me = PMDPe(E, P, λ, B, A, objective)
    return mg, me
end

