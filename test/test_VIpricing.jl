using PricingMDP

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

using Traceur
using XLSX
using BSON

include("PMDP_instances/e2.jl")

# POMDPLinter.@requirements_info SparseValueIterationSolver() mdp
# @requirements_info ValueIterationSolver() mdp

function value_heuristic(s::State, m::PMDP)
    α_t = 1.0/m.T
    α_c = 15.
    α_t*(m.T-s.t)*α_c*sum(s.c) 
end
init_util = [value_heuristic(mdp.states[i], mdp) for i in 1:length(mdp.states)]

solver = SparseValueIterationSolver(max_iterations=100, belres=1e-6, verbose=true)#, init_util=init_util) # creates the solver
# POMDPs.@show_requirements POMDPs.solve(solver, mdp)

println("Solving...")
policy = solve(solver, mdp)
println("Done.")

# bson("policy.bson", Dict(:policy => policy))
# BSON.load("policy.bson")

# Get action counts
df = DataFrame(pricei = policy.policy)
df[:, :price] = [policy.action_map[i] for i in df.pricei]
combine(groupby(df, :price), nrow)


qmat = policy.qmat
non_zero_Q_states = (sum(qmat, dims = 2).>0)[:,1]
qmat[non_zero_Q_states, :]

qdf = DataFrame(hcat( [repr(mdp.states[i].c) for i in 1:length(mdp.states)],
                      [mdp.states[i].t for i in 1:length(mdp.states)], 
                      [repr(mdp.states[i].p) for i in 1:length(mdp.states)],policy.qmat), 
                map(Symbol, vcat(["c", "t", "p"], policy.action_map)))

rm("q_mat.xlsx", force=true)
XLSX.writetable("q_mat.xlsx", qdf)

hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=MersenneTwister(1234))
h = simulate(hr, mdp, policy)
collect(eachstep(h, "s, a, r"))
sum(h[:r])