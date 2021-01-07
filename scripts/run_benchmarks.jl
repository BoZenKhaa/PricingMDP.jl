using PMDPs
using POMDPs
using BSON, CSV
using DrWatson
using RandomNumbers.Xorshifts
using Random
using MCTS, DiscreteValueIteration
using DataFrames

using POMDPSimulators
using StaticArrays, Distributions # load pp

pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5.)))
sname = savename("traces_lp", pp_params,  "bson")
data = load(datadir("traces", sname))
traces = data[:traces]
pp = data[:pp]

mg = PMDPs.PMDPg(pp)
me = PMDPs.PMDPe(pp)
rnd = Xorshift128Plus(1516)

flatrate = PMDPs.get_flatrate_policy(mg, [PMDPs.simulate_trace(mg, rnd) for i in 1:500])

results = PMDPs.eval(mg, traces, @ntuple(flatrate), MersenneTwister(1))
agg = describe(res_flatrate, cols=1:4)

# action(flatrate, POMDPs.initialstate(mg))

result_dir = datadir("results", "linear_problem")
mkpath(result_dir)
save(datadir("results", "linear_problem", savename("flatrate", pp_params, "bson")), @dict(results, agg))

load(datadir("results", savename(pp_params), "flatrate.bson"))



collect_results!(datadir("results"); subfolders=true)

# VI
# vi = PMDPs.get_VI_policy(me)
# TODO: Save policy for given mdp

# MCTS
mcts = PMDPs.get_MCTS_planner(mg; params_mcts = Dict(:rng=>rnd))

hindsight = PMDPs.LP.get_MILP_hindsight_policy(mg, traces[1])

policies = @ntuple(vi, mcts, flatrate, hindsight)

PMDPs.eval(mg, traces[1], policies, MersenneTwister(1))


for trace in traces[1:2]
    hrpl = PMDPs.HistoryReplayer(mg, trace)
    hrec = HistoryRecorder(max_steps = PMDPs.selling_period_end(mg), rng = rnd)
    
    # VI
    hᵥ = simulate(hrec, hrpl, policy)
        
    # MCTS
    hₘ = simulate(hrec, hrpl, planner)

    # hindsight
    hₕ = simulate(hrec, hrpl, hindsight)

    # flatrate
    # R, U = PMDPs.optimize_flatrate_policy(mg, [trace, trace])
    hᵣ = simulate(hrec, hrpl, flatrate)
end


