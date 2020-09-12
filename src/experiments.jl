using MCTS, DiscreteValueIteration

function get_VI_policy(mdp::PMDPe)
    solver = SparseValueIterationSolver(max_iterations=100, belres=1e-6, verbose=true)#, init_util=init_util) # creates the solver
    # POMDPs.@show_requirements POMDPs.solve(solver, mdp)
    policy = solve(solver, mdp)
end

function get_MCTS_planner(mdp::PMDPg)
    solver = MCTSSolver(n_iterations=100, depth=100, exploration_constant=10.0)
    planner = solve(solver, mdp)
    # s = PricingMDPv1.State(SA[1,1,1], 0, SA[1,0,0])
    # a = action(planner, s)
end
