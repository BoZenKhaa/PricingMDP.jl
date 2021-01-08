function get_VI_policy(mdp::PMDPe)
    solver = SparseValueIterationSolver(max_iterations=100, belres=1e-6, verbose=false)#, init_util=init_util) # creates the solver
    # POMDPs.@show_requirements POMDPs.solve(solver, mdp)
    policy = solve(solver, mdp)
end

function get_VI_policy(params::Dict)
    Dict(:policy => get_VI_policy(params[:mdp]))
end

function get_MCTS_planner(mdp::PMDPg; params_mcts::Dict=Dict()) 
    mcts_defaults = Dict(pairs( (
                 solver= DPWSolver, n_iterations=50, depth=30, 
                 exploration_constant=40.0, enable_state_pw = true, 
                 keep_tree=true, show_progress=false, rng=MersenneTwister())))

    mcts_params = merge(mcts_defaults, params_mcts)
    
    solver_method = pop!(mcts_params, :solver)
    solver = solver_method(;mcts_params...)
    
    planner = solve(solver, mdp)
end