using PMDPs

function super_simple_pp()
    T = 3
    P = SA[ PMDPs.Product(SA[true], T),] 
    C₀ = SA[1,]
    D = BernoulliScheme(T, [0.1]) 
    β = DiscreteNonParametric([10.], [1.])
    B = [β,]
    A = [0., 5., 10., 15.]
    objective = :revenue

    pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
end

function simple_pp()
    P = SA[ PMDPs.Product(SA[true, false], 6), # 1
            PMDPs.Product(SA[false, true], 8), # 2
            PMDPs.Product(SA[true, true], 6)]  # 3
    C₀ = SA[3,3]
    D = BernoulliScheme(8, [0.1, 0.1, 0.1]) 
    β₁ = DiscreteNonParametric([10.], [1.])
    β₂ = DiscreteNonParametric([10.,15.], [0.5, 0.5])
    B = [β₁, β₁, β₂]
    A = [0., 5., 10., 15.]
    objective = :revenue

    pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
end

function simple_short_trace(pp::PMDPs.PMDPProblem)
    SimHistory([
        (s = PMDPs.State(pp.c₀, 1, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 3, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 5, 2), info = (b=10.,))
    ], 1., nothing, nothing)
end

"""
TODO: remove pp from args
"""
function simple_exhaust_capacity_trace(pp::PMDPs.PMDPProblem)
    pp = super_simple_pp()
    trace = SimHistory([
        (s = PMDPs.State(pp.c₀, 1, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 2, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 3, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 4, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 5, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 6, 3), info = (b=15.,)),
        # (s = PMDPs.State(pp.c₀, 7, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 8, 2), info = (b=10.,))
    ], 1., nothing, nothing)
    pp, trace
end

function simple_trace_different_utility_revenue_optim_allocs(pp::PMDPs.PMDPProblem)
    SimHistory([
        # (s = PMDPs.State(pp.c₀, 1, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 2, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 3, 3), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 4, 2), info = (b=10.,)),
        # (s = PMDPs.State(pp.c₀, 5, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 6, 3), info = (b=10.,)),
        # (s = PMDPs.State(pp.c₀, 7, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 8, 2), info = (b=10.,))
    ], 1., nothing, nothing)
end

function empty_trace(pp::PMDPs.PMDPProblem)
    empty_trace = SimHistory([
        (s=PMDPs.State(pp.c₀, 1, length(pp.P)+1), info = (b=PMDPs.EMPTY_PRODUCT_USER_BUDGET,)),
        ], 1., nothing, nothing)
end