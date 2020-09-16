using PricingMDP
using Test

using POMDPSimulators
using POMDPs
using Random

mdp_mc = PricingMDP.create_PMDP(PMDPg) 
planner = PricingMDP.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(123)
hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
h = simulate(hr, mdp_mc, planner)
trace = collect(eachstep(h, "s, a, r, info"))

PricingMDP.LP.MILP_hindsight_pricing(mdp_mc, h)