using PMDPs
using Test

using POMDPSimulators
using POMDPs
using Random

mdp_mc = PMDPs.create_PMDP(PMDPg)
planner = PMDPs.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(123)
hr = HistoryRecorder(max_steps = 100, capture_exception = false, rng = rng)
h = simulate(hr, mdp_mc, planner)
trace = collect(eachstep(h, "s, a, r, info"))

PMDPs.LP.MILP_hindsight_pricing(
    mdp_mc,
    h,
    optimization_goal = "utilization",
    verbose = false,
)
