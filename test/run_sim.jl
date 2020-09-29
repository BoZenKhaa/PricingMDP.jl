using PricingMDP
using Test
using POMDPSimulators

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
using Plots
using POMDPSimulators
using D3Trees
using POMDPPolicies
using POMDPLinter
using Random
using DataFrames
using POMDPSimulators


mdp_vi = PricingMDP.create_PMDP(PMDPe)
mdp_mc = PricingMDP.create_PMDP(PMDPg) 

policy = PricingMDP.get_VI_policy(mdp_vi)
planner = PricingMDP.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(1234)

s0 = rand(rng, initialstate(mdp_mc))

# function run_sim(mdp::PMDP, policy::Policy; rng_seed=1234)
#     rng = MersenneTwister(rng_seed)
#     hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
#     h = simulate(hr, mdp, policy)
#     collect(eachstep(h, "s, a, r, user_budget"))
#     # sum(h[:r])
# end

rng_seed = 1
max_steps = mdp_mc.T+1

# rng = MersenneTwister(rand_seed)
# hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
# h_mc = simulate(hr, mdp_mc, planner)
# collect(eachstep(h, "s, a, r, info"))

h_mc = run_sim(mdp_mc, planner; max_steps = max_steps, rng_seed = rng_seed)
h_vi = run_sim(mdp_mc, policy; max_steps = max_steps, rng_seed = rng_seed)


hindsight = PricingMDP.LP.MILP_hindsight_pricing(mdp_mc, h_mc; optimization_goal="revenue", verbose=false)

function get_stats(h::SimHistory)
    n = sum(sum(s.p)>0 for s in h[:s])
    T = length(h)
    r = sum(h[:r])

    return (T=T, r=r, n=n)
end


hindsight[:r], get_stats(h_mc), get_stats(h_vi)

h = h_mc
mdp = mdp_mc

# extract request trace from history
trace = collect(eachstep(h, "s, info"))
requests = [rec for rec in trace if rec.s.p!=mdp.empty_product]

# get data from trace
request_edges = [[rec.s.p...] for rec in requests]
request_budgets = [rec.info for rec in requests]

requests[1].s

# Chech revenue of each flatrate
r_max = 0
for a in mdp.actions
    c = [e.c_init for e in mdp.E]
    r_a = 0
    for i in 1:length(requests)
        if ~PricingMDP.sale_impossible(mdp, c, requests[i].s.p) && a < request_budgets[i]
            c -= requests[i].s.p
            r_a +=a
        end
    end
    println(r_a)
    # r_a>r_max ? r_max=r_a : r_max
end

# @show run_sim(mdp_mc, policy; rng_seed = 1235)

# ch = run_sim(mdp_mc, planner; rng_seed = 1236)
# @show ch
# any(ch[end][:s].c .< 0)


# for i in 1:10000
#     ch = run_sim(mdp_vi, planner; rng_seed = i)
#     print(i, " ")
#     any(ch[end][:s].c .< 0) ? break : continue
# end
# action(planner, s0)