using PMDPs
# using PMDPs.LP
using POMDPs

using StaticArrays
# using Distributions
# using DiscreteValueIteration
# using Printf
# using Random

# using D3Trees
# using AbstractTrees
# using Colors

using PMDPs.CountingProcesses
using RandomNumbers.Xorshifts

using BenchmarkTools
using Distributions
# using DrWatson

using MCTS
# using POMDPSimulators
# using POMDPPolicies
# using DiscreteValueIteration

# using Formatting

# import Base.show

# using Plots
# using Distributions
# using ProgressMeter

# using DataFrames

# using Profile, FlameGraphs #, ProfileView

# PROBLEM

nᵣ = 12
pp_params = Dict(pairs((
                nᵣ = nᵣ,
                c = 5,
                T = Int64(nᵣ*24),
                expected_res = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
                res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
                objective = :revenue,
            )))
pp = PMDPs.single_day_cs_pp(;pp_params...)
PMDPs.statespace_size(pp)

mg = PMDPs.PMDPg(pp)


# SOLVER
RNG = Xorshift1024Plus

params_classical_MCTS = Dict(
    pairs((
        depth = 3,
        exploration_constant = 10.,
        n_iterations = 10000,
        enable_tree_vis=true,
        reuse_tree = false,
        sizehint=100_000,
    )),
)

solver = PMDPs.MCTS.MCTSSolver(; params_classical_MCTS..., rng = RNG(1), sizehint=100_000)
planner = PMDPs.MCTS.solve(solver, mg);
s₀ = rand(initialstate(mg))


a = POMDPs.action(planner, s₀)

GC.enable_logging(false)

# @benchmark POMDPs.action($planner, $s₀)


function benchmark_action_setup(mg)
    RNG = Xorshift1024Plus

    solver = PMDPs.MCTS.MCTSSolver(;
        depth = 5,
        exploration_constant = 10.,
        n_iterations = 10000,
        enable_tree_vis=true,
        reuse_tree = false, 
        rng = RNG(1), 
        estimate_value=PMDPs.MCTS.RolloutEstimator(PMDPs.MCTS.RandomSolver(RNG(1))),
        sizehint=100_000)
    
    planner = PMDPs.MCTS.solve(solver, mg)
    return planner
end

3+3

SUITE = BenchmarkGroup()

SUITE["large_cs_mcts"] = BenchmarkGroup(["CS", "MCTS"])

SUITE["large_cs_mcts"]["action"] = @benchmarkable POMDPs.action(inputs, $s₀) setup=(inputs = benchmark_action_setup($mg)) gcsample=false gctrial=true

# tune!(SUITE)

# results = run(SUITE, verbose = true, seconds = 5)

# t = @benchmark POMDPs.action(inputs, $s₀) setup=(inputs = benchmark_action_setup($mg)) gcsample=false gctrial=true
# maximum(t)
# dump(t)

# # PROFILING
# Profile.clear()
# @profile POMDPs.action(planner, s₀)

# g = flamegraph()
# # @profile plot(rand(5))
# g = flamegraph(C=true)

# @profview POMDPs.action(planner, s₀)