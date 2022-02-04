using PMDPs
using PMDPs.LP
using DrWatson
using RandomNumbers.Xorshifts
using MCTS
using POMDPSimulators
using POMDPPolicies
using DiscreteValueIteration

using Formatting

import Base.show

using Plots
using Distributions
using ProgressMeter


using POMDPs
using DataFrames

RND = Xorshift1024Plus

include(srcdir("MDPPricing.jl"))

OUT_FOLDER = "profiling"

PP_NAME = "single_day_pp"


"""
PREP TRACES
"""
nᵣ=6
pp_params = Dict(pairs((
    nᵣ = 6,
    c = 3,
    T = nᵣ*7,
    expected_res = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
    res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
    objective = :revenue,
)))
println("nᵣ = ", nᵣ)
pp = PMDPs.single_day_cs_pp(;pp_params...)
PMDPs.statespace_size(pp)

vi = true
name = PP_NAME
n_traces =100
input = PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1)

"""
PREP SOLVER
"""
params_classical_MCTS = Dict(
    pairs((
        depth = 3,
        exploration_constant = 1.,
        n_iterations = 100,
        reuse_tree = true,
        rng = RND(1),
    )),
)
mcts_params_note = "_unlimited_rollout"
function MCTS.rollout(estimator::MCTS.SolvedRolloutEstimator, mdp::MDP, s, d::Int)
    sim = RolloutSimulator(;estimator.rng, eps=nothing, max_steps=nothing)
    POMDPs.simulate(sim, mdp, estimator.policy, s)
end

# MCTSSolver(; params_classical_MCTS...)
N_traces=100

"""
RUN

Baseline @time:
    40.342130 seconds (341.02 M allocations: 13.037 GiB, 6.28% gc time) 

Pre-computing StaggeredBernoulliScheme @time:
    10.626524 seconds (100.19 M allocations: 3.683 GiB, 7.20% gc time)

With skips over states with no products @time:
    2.213717 seconds (17.72 M allocations: 841.344 MiB, 7.72% gc time)
"""

using StatProfilerHTML
using Traceur

# @trace 
# time
@profilehtml PMDPs.process_data(
    input,
    PMDPs.mcts;
    folder = OUT_FOLDER,
    N = N_traces,
    method_info = "vanilla$(mcts_params_note)_$(savename(params_classical_MCTS))",
    solver_params=params_classical_MCTS,
    solver = MCTSSolver(;params_classical_MCTS...),
)
