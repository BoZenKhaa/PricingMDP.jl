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

"""
Compare actions given by VI and MCTS across all states in the MDP
"""
function compare_actions(mdp_vi::PMDPe, vi_policy::ValueIterationPolicy, mc_planner::MCTSPlanner; rng_seed=123)
    rng = MersenneTwister(rng_seed)
    println("\t\t\t\t\t\t\t\t Actions: ", mdp_vi.actions)
    bad_a = 0
    for i in 1:length(mdp_vi.states)
    #     s_i = rand(rng, 1:length(mdp_vi.states))
        s = mdp_vi.states[i]
        a_vi = action(vi_policy, s)
        a_mc = action(mc_planner, s)
        if a_vi!=a_mc && abs(a_vi - a_mc)!=1000
            Q_s = vi_policy.qmat[stateindex(mdp_vi, s),:]
            q_Δ = Q_s[actionindex(mdp_vi, a_vi)] - Q_s[actionindex(mdp_vi, a_mc)]
            print("$s: a_vi=$a_vi, a_mc=$a_mc, q_Δ=$q_Δ Q:")
            println(Q_s)
            bad_a+=1
        end
    end
    print("Total of $bad_a bad actions")
end

function run_sim(mdp::PMDP, policy::Policy; rng_seed=1234)
    rng = MersenneTwister(rng_seed)
    hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
    h = simulate(hr, mdp, policy)
    collect(eachstep(h, "s, a, r, user_budget"))
    # sum(h[:r])
end