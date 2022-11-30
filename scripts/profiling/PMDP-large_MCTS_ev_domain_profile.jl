using PMDPs
using PMDPs.LP
using PMDPs.CountingProcesses
using POMDPs
using POMDPSimulators
using POMDPPolicies
using MCTS
using DiscreteValueIteration

using StaticArrays
using Distributions
using Random
# using DrWatson
# import Base.show
# using Plots
# using ProgressMeter
# using DataFrames

using BenchmarkTools
using PProf, Profile, FlameGraphs #, ProfileView
using JET



# PROBLEM

nᵣ = 12
pp_params = Dict(pairs((
                nᵣ = nᵣ,
                c = 5,
                T = Int64(nᵣ*24),
                expected_res = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
                res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
                objective = PMDPs.REVENUE,
            )))
pp = PMDPs.single_day_cs_pp(;pp_params...)
# PMDPs.statespace_size(pp)

mg = PMDPs.PMDPg(pp)


# SOLVER
RNG = Xoshiro

params_classical_MCTS = Dict(
    pairs((
        depth = 5,
        exploration_constant = 10.,
        n_iterations = 10000,
        enable_tree_vis=true,
        reuse_tree = false,
        # sizehint=100_000,
    )),
)

solver = MCTS.MCTSSolver(; params_classical_MCTS..., rng = RNG(1))

planner = PMDPs.MCTS.solve(solver, mg);
s₀ = rand(initialstate(mg))


# JET analysis
@report_call POMDPs.action(planner, s₀)
@report_opt POMDPs.action(planner, s₀)

# GC.enable_logging(false)

# PROFILING
Profile.clear()
@profview POMDPs.action(planner, s₀)

# MEMORY PROFILING
@time POMDPs.action(planner, s₀)

Profile.clear()
Profile.Allocs.@profile POMDPs.action(planner, s₀)
PProf.Allocs.pprof()
