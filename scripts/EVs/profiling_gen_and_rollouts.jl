using PMDPs
using PMDPs.LP
using DrWatson
using Random
using MCTS
using POMDPTools
using POMDPTools
using DiscreteValueIteration

using Format

import Base.show

using BenchmarkTools

# using Plots
using Distributions
# using ProgressMeter
# using DataFrames


using POMDPs

RNG = Xoshiro

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
input = PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1, save=false)

"""
PREP SOLVER
"""
params_classical_MCTS = Dict(
    pairs((
        depth = 3,
        exploration_constant = 1.,
        n_iterations = 100,
        reuse_tree = true,
        rng = RNG(1),
    )),
)
mcts_params_note = "_unlimited_rollout"
function MCTS.rollout(estimator::MCTS.SolvedRolloutEstimator, mdp::PMDPs.PMDPg, s, d::Int)
    sim = RolloutSimulator(;estimator.rng, eps=nothing, max_steps=nothing)
    POMDPs.simulate(sim, PMDPs.PMDPgr(mdp), estimator.policy, s)
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

Fixing type instability in the old gen function, NO skips @time:
    4.350813 seconds (39.88 M allocations: 1.942 GiB, 9.37% gc time)

Fixing type instability in the old gen function, WITH skips @time:
    1.430212 seconds (13.22 M allocations: 632.143 MiB, 25.72% gc time, 0.84% compilation time)

PMDPgr in rollouts, PMDPg in tree @time:
    2.475870 seconds (21.29 M allocations: 1.023 GiB, 9.53% gc time)

PMDPgr in rollouts, PMDPg in tree while caching PMDPgr in PMDPg @time:
    2.428882 seconds (21.38 M allocations: 1.074 GiB, 10.46% gc time)

==================================
Split gen functions, returning tuples
    12.621273 seconds (139.96 M allocations: 4.399 GiB, 5.62% gc time)

Old gen function
    11.255265 seconds (100.21 M allocations: 3.684 GiB, 10.81% gc time)
"""

using StatProfilerHTML
using Traceur
using Random

# @trace PMDPs.process_data(
@time PMDPs.process_data(
# @profilehtml PMDPs.process_data(
    input,
    PMDPs.mcts;
    folder = OUT_FOLDER,
    N = N_traces,
    method_info = "vanilla$(mcts_params_note)_$(savename(params_classical_MCTS))",
    solver_params=params_classical_MCTS,
    solver = MCTSSolver(;params_classical_MCTS...),
)



# Timing MCTS action
nᵣ = 48
pp_params = Dict(pairs((
    nᵣ = nᵣ,
    c = 3,
    T = nᵣ*7,
    expected_res = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
    res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
    objective = :revenue,
)))

params_classical_MCTS = Dict(
    pairs((
        depth = 3,
        exploration_constant = 1.,
        n_iterations = 800,
        reuse_tree = true,
        rng = RNG(1),
    )),
)

mg = PMDPs.PMDPg(pp)
s = rand(initialstate(mg))
a = actions(mg)[8]
mgr = PMDPs.PMDPgr(mg)
solver = MCTSSolver(;params_classical_MCTS...)
policy = solve(solver, mg)

@btime action(policy, s)

"""
Investigating method
"""

using Debugger

using PMDPs
using POMDPs

mg = PMDPs.PMDPg(pp)
s = rand(initialstate(mg))
a = actions(mg)[8]

mgr = PMDPs.PMDPgr(mg)

PMDPs.gen(mg, s, a, RNG(1))
# PMDPs.gen_(mg, s, a, RNG(1))

@code_warntype PMDPs.sample_request(mg, s.t + 1, RNG(1))

@code_typed PMDPs.gen(mg, s, a, RNG(1))
@code_typed PMDPs.gen_(mg, s, a, RNG(1))

@code_lowered PMDPs.gen(mg, s, a, RNG(1))
@code_lowered PMDPs.gen_(mg, s, a, RNG(1))

@code_llvm PMDPs.gen(mg, s, a, RNG(1))
@code_llvm PMDPs.gen_(mg, s, a, RNG(1))

@code_warntype PMDPs.gen(mg, s, a, RNG(1))

@code_warntype PMDPs.calculate_reward(PMDPs.pp(mg), PMDPs.product(mg, s), a)

@code_warntype PMDPs.pp(mg)


"""
Testing value types
"""

abstract type AbstractTest{A, O} <: Any end

# struct MyType{A, O} <: AbstractTest{A, O} 
#     a::A
# end

t1 = MyType{Int64, :AHOJ}(12)
t2 = MyType{Int64, :HELE}(12)

fun(t::AbstractTest{A, :AHOJ}) where A  = print("Ahoj")
fun(t::AbstractTest{A, :HELE}) where A  = print("Hele")
fun(t1)
fun(t2)

struct MyType{O}
    a::Int64
end

struct MMType
    m::MyType{O} where O
    b::Float64
end

t = MMType(MyType{:AHOJ}(10), 12.0)

fun(t::MMType) = t.m

@code_warntype fun(t)