using FiniteHorizonPOMDPs


run(`clear`)

@testset "finite_horizon" begin
    pp = simple_pp()
    me = PMDPs.PMDPe(pp)

    # Solve Value Iteration
    solver = ValueIterationSolver(max_iterations=1000, belres=1e-3, include_Q=true);
    VIPolicy = DiscreteValueIteration.solve(solver, me);

    fhsolver = FiniteHorizonSolver(false)

    # FH
    FHPolicy = POMDPs.solve(fhsolver, me)

    for s in states(me)
        # if !PMDPs.sale_impossible(me,s)
            @test FiniteHorizonPOMDPs.action(FHPolicy, s) == action(VIPolicy, s)
            # display("$(FiniteHorizonPOMDPs.stage_stateindex(me, s, 1)) - $s - $(PMDPs.product(me, s))")
        # end

        # if FiniteHorizonPOMDPs.action(FHPolicy, s) != action(VIPolicy, s)
        #     print(PMDPs.sale_impossible(me, s), " ")
        #     display(s) 
        # end
    end



    # [FiniteHorizonPOMDPs.stage_stateindex(me, s, 1) for s in states(me)]
    # [stateindex(me, s)]
    # FiniteHorizonPOMDPs.action(FHPolicy, s)
end