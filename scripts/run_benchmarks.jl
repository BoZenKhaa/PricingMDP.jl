using PMDPs
using PMDPs.LP
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
data = PMDPs.load_traces(datadir("traces", sname))

N=10000
PMDPs.process_data(data, PMDPs.flatrate; N=N)
PMDPs.process_data(data, PMDPs.hindsight; N=N)
PMDPs.process_data(data, PMDPs.vi; N=N)
PMDPs.process_data(data, PMDPs.mcts; N=N)

println("Done.")