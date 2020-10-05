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
Calculate, how many resources were utilized in simulation run

get_utilization(h_mc)
"""
function get_utilization(h::AbstractSimHistory)
    s = collect(h[:s])
    u = sum(s[1].c - s[end].c)
    return u
end


"""
Get stats for given sim history, 
    :r revenue
    :T nunber of steps
    :n_req number of non empty requests
    :u utilization
"""
function get_stats(h::SimHistory)
    n_req = sum(sum(s.p)>0 for s in h[:s])
    T = length(h)
    r = sum(h[:r])
    u = get_utilization(h)

    return (r=r, u = u, T=T, n_req=n_req)
end

"""Using an array of multiple simulation outputs from flatrate, calculate revenue and utilization"""
function flatrate_stats(flat::NamedTuple)
    r_sum = sum(flat[:r])/length(flat[:r])
    flat_ai = argmax(r_sum)

    flat_r = r_sum[flat_ai]
    flat_u = (sum(flat[:u])/length(flat[:u]))[flat_ai]
    return (r = flat_r, u = flat_u)
end

"""
Run "n_runs" simulations. Evaluate each run with each benchmark and method. Collect statistics. 
"""
function makesim(params::Dict; n_runs = 20, vi = true)
    mdp_mc = PricingMDP.create_PMDP(PMDPg; params[:mdp]...) 
    planner = PricingMDP.get_MCTS_planner(mdp_mc, params[:mcts])
    
    if vi
        mdp_vi = PricingMDP.create_PMDP(PMDPe; params[:mdp]...)
        policy = PricingMDP.get_VI_policy(mdp_vi)
    else
        mdp_vi = nothing
        policy = nothing
    end
    # rng = MersenneTwister(1234)

    # rng_seed = 1
    max_steps = mdp_mc.T+1
    revenues = []
    utilizations = []
    hs_mc = []
    hs_vi = []
    flat_r, flat_u = [], []

    print("Running $n_runs sim runs: ")
    for rng_seed in 1:n_runs
        print(rng_seed)

        h_mc = run_sim(mdp_mc, planner; max_steps = max_steps, rng_seed = rng_seed)
        push!(hs_mc, h_mc)
        
        hindsight = PricingMDP.LP.MILP_hindsight_pricing(mdp_mc, h_mc; optimization_goal="revenue", verbose=false)
        flatrate = PricingMDP.flatrate_pricing(mdp_mc, h_mc)
        push!(flat_r, flatrate[:r_a])
        push!(flat_u, flatrate[:u_a])

        if vi
            h_vi = run_sim(mdp_mc, policy; max_steps = max_steps, rng_seed = rng_seed)
            push!(hs_vi, h_vi)
        end

        mc_stats = get_stats(h_mc)
        if vi
            vi_stats = get_stats(h_vi)
            push!(revenues, [mc_stats[:r], vi_stats[:r], hindsight[:r]])
            push!(utilizations, [mc_stats[:u], vi_stats[:u], hindsight[:u]])
        else
            push!(revenues, [mc_stats[:r], -1, hindsight[:r]])
            push!(utilizations, [mc_stats[:u], -1, hindsight[:u]])
        end
    end

    flat_r, flat_u = flatrate_stats((r = flat_r, u = flat_u))
    mc_r, vi_r, hind_r = sum(revenues)./length(revenues)
    mc_u, vi_u, hind_u = sum(utilizations)./length(utilizations)

    return (r=(flat = flat_r, mc = mc_r, vi = vi_r, hind = hind_r),  # Average revenue and utilization for each method
            u = (flat = flat_u, mc = mc_u, vi = vi_u, hind = hind_u),  # Average utilization for each method
            hs_mc=hs_mc, hs_vi = hs_vi, # Array of histories for mc and vi
            mdp_mc=mdp_mc, mdp_vi=mdp_vi, # mdps
            policy = policy, planner = planner, # planners and policies
            flat = (r = flat_r, u = flat_u), # flat rate output arrays
            rs=revenues, us = utilizations,) # revenues and utilizations for each method, except flatrate
end