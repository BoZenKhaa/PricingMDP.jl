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
using RandomNumbers.Xorshifts
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
                c = 3,
                T = 100,
                expected_res = 3.0,
                res_budget_μ = 5.0,
                different_selling_period_ends=false,
                objective = PMDPs.REVENUE,
            )))
pp = PMDPs.linear_pp(nᵣ; pp_params...)
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
        sizehint=100_000,
    )),
)

solver = MCTS.MCTSSolver(; 
    params_classical_MCTS..., 
    rng = RNG(1), 
    sizehint=100_000)

function MCTS.estimate_value(estimator::MCTS.SolvedRolloutEstimator,  mdp::PMDPs.PMDPg, state, remaining_depth)
    MCTS.estimate_value(estimator, PMDPs.PMDPgr(PMDPs.pp(mdp)), state, remaining_depth)
end


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
