using PMDPs

function simple_pp()
    P = SA[ PMDPs.Product(SA[true, false], 6), 
            PMDPs.Product(SA[false, true], 8), 
            PMDPs.Product(SA[true, true], 6)]
    C₀ = SA[3,3]
    D = BernoulliScheme(8, [0.1, 0.1, 0.1]) 
    β = DiscreteNonParametric([10.], [1.])
    B = [β, β, β]
    A = [0., 5., 10., 15.]
    objective = :revenue

    pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
end

function simple_trace(pp::PMDPs.PMDPProblem)
    SimHistory([
        (s = PMDPs.State(pp.c₀, 1, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 3, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 5, 2), info = (b=10.,))
    ], 1., nothing, nothing)
end

function empty_trace(pp::PMDPs.PMDPProblem)
    empty_trace = SimHistory([
        (s=PMDPs.State(pp.c₀, 1, length(pp.P)+1), info = (b=PMDPs.EMPTY_PRODUCT_USER_BUDGET,)),
        ], 1., nothing, nothing)
end