using MCTS, DiscreteValueIteration 
using POMDPSimulators

function get_VI_policy(mdp::PMDPe)
    solver = SparseValueIterationSolver(max_iterations=100, belres=1e-6, verbose=true)#, init_util=init_util) # creates the solver
    # POMDPs.@show_requirements POMDPs.solve(solver, mdp)
    policy = solve(solver, mdp)
end

function get_MCTS_planner(mdp::PMDPg, params_mcts::Dict)
    solver = MCTSSolver(;params_mcts...)
    planner = solve(solver, mdp)
    # s = PricingMDPv1.State(SA[1,1,1], 0, SA[1,0,0])
    # a = action(planner, s)
end

"""
Compare actions given by VI and MCTS across all states in the MDP
"""
function compare_actions(mdp_vi::PMDPe, vi_policy::ValueIterationPolicy, mc_planner::MCTSPlanner; rng_seed=123, verbose=false)
    rng = MersenneTwister(rng_seed)
    if verbose
        println("\t\t\t\t\t\t\t\t Actions: ", mdp_vi.actions)
    end
    bad_a = 0
    avg_q_Δ=0
    avg_a_Δ = 0
    for i in 1:length(mdp_vi.states)
    #     s_i = rand(rng, 1:length(mdp_vi.states))
        s = mdp_vi.states[i]
        a_vi = action(vi_policy, s)
        a_mc = action(mc_planner, s)
        if a_vi!=a_mc && abs(a_vi - a_mc)!=1000
            Q_s = vi_policy.qmat[stateindex(mdp_vi, s),:]
            q_Δ = Q_s[actionindex(mdp_vi, a_vi)] - Q_s[actionindex(mdp_vi, a_mc)]
            avg_q_Δ += q_Δ
            avg_a_Δ += abs(a_vi - a_mc)
            if verbose
                print("$s: a_vi=$a_vi, a_mc=$a_mc, q_Δ=$q_Δ Q:")
                println(Q_s)
            end
            bad_a+=1
        end
    end
    n_S = length(mdp_vi.states) 
    print("Total of $bad_a bad actions of $n_S")
    return bad_a, avg_q_Δ/bad_a, avg_a_Δ/bad_a
end

function run_sim(mdp::PMDP, policy::Policy; max_steps=10, rng_seed=1234)
    rng = MersenneTwister(rng_seed)
    hr = HistoryRecorder(max_steps=max_steps, capture_exception=true, rng=rng)
    h = simulate(hr, mdp, policy)
    return h
    # collect(eachstep(h, "s, a, r, info"))
    # sum(h[:r])
end

"""
Get stats for given sim history, 
    :r revenue
    :T nunber of steps
    :n number of non empty requests
"""
function get_stats(h::SimHistory)
    n = sum(sum(s.p)>0 for s in h[:s])
    T = length(h)
    r = sum(h[:r])

    return (r=r, T=T, n=n)
end

function makesim(params::Dict; n_runs)
    mdp_vi = PricingMDP.create_PMDP(PMDPe; params[:mdp]...)
    mdp_mc = PricingMDP.create_PMDP(PMDPg; params[:mdp]...) 

    policy = PricingMDP.get_VI_policy(mdp_vi)
    planner = PricingMDP.get_MCTS_planner(mdp_mc, params[:mcts])

    # rng = MersenneTwister(1234)

    # rng_seed = 1
    max_steps = mdp_mc.T+1
    revenues = []
    histories = []

    print("Running $n_runs sim runs: ")
    flat_r_a = []
    for rng_seed in 1:n_runs
        print(rng_seed)
        h_mc = run_sim(mdp_mc, planner; max_steps = max_steps, rng_seed = rng_seed)
        h_vi = run_sim(mdp_mc, policy; max_steps = max_steps, rng_seed = rng_seed)

        hindsight = PricingMDP.LP.MILP_hindsight_pricing(mdp_mc, h_mc; optimization_goal="revenue", verbose=false)
        flatrate = PricingMDP.flatrate_pricing(mdp_mc, h_mc)
        push!(histories, [h_mc, h_vi])
        push!(revenues, [flatrate[:r], get_stats(h_mc)[:r], get_stats(h_vi)[:r], hindsight[:r]])
        push!(flat_r_a, flatrate[:r_a])
    end

    return (r=revenues, h=histories, mdp_mc=mdp_mc, mdp_vi=mdp_vi, policy = policy, planner = planner, flat_r_a = flat_r_a)
end