function get_VI_policy(mdp::PMDPe)
    solver = SparseValueIterationSolver(max_iterations=100, belres=1e-6, verbose=false)#, init_util=init_util) # creates the solver
    # POMDPs.@show_requirements POMDPs.solve(solver, mdp)
    policy = DiscreteValueIteration.solve(solver, mdp)
end

function get_VI_policy(params::Dict)
    Dict(:policy => get_VI_policy(params[:mdp]))
end

function get_FHVI_policy(mdp::PMDPe)
    solver = FiniteHorizonSolver(false)
    FHPolicy = POMDPs.solve(solver, mdp)
end

function get_MCTS_planner(mdp::PMDPg; params_mcts::Dict=Dict()) 
    mcts_defaults = Dict(pairs((
                 solver= DPWSolver, depth=50, 
                 exploration_constant=40.0, enable_state_pw = false, 
                 keep_tree=true, show_progress=false, rng=Xorshift128Plus())))

    mcts_params = merge(mcts_defaults, params_mcts)
    
    solver_method = pop!(mcts_params, :solver)
    solver = solver_method(;mcts_params...)
    
    planner = MCTS.solve(solver, mdp)
end

