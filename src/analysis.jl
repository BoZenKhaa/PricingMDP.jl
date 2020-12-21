"""
Tools and helper functions for analyzing the results
"""


"""
Returns analysis of how many times heuristic MCTS planner returns action that is 
different from the VI (assumed to be optimal). 

The method calculates this across all MDP states, so it only works for small problem instances.
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

