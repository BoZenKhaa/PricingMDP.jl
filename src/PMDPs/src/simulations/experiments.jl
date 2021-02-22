function run_small_instances()
    mdp_params = Dict(pairs( (n_edges = 3, c_init = 2, demand = Float64[1,1,1], selling_horizon_end = [40,45,50], actions = 15:5:90, objective=:revenue)))
    #mdp_params = Dict(pairs( (n_edges = 2, c_init = 1, demand = Float64[1,1], selling_horizon_end = [20,25], actions = 15:5:30)))
    # mcts_params = Dict(solver= MCTSSolver, n_iterations=1000, depth=30, exploration_constant=40.0, reuse_tree=true)
    mcts_params = Dict(pairs( (solver= DPWSolver, n_iterations=50, depth=30, exploration_constant=40.0, enable_state_pw = true, keep_tree=true, show_progress=false)))
    exp_params = Dict(pairs( (n_runs = 20, vi=true, save=:stats) ))
    params = Dict(:mdp=>mdp_params, :mcts=>mcts_params, :exp=>exp_params)

end