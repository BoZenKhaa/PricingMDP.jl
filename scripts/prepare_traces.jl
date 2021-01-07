using PMDPs
using RandomNumbers.Xorshifts
using DrWatson
using BSON

using POMDPSimulators # load histories
using StaticArrays, Distributions # load

const N = 10000 # number of traces
pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5.)))
name = "linear_problem"
pp = PMDPs.linear_pp(;pp_params...)
mg = PMDPs.PMDPg(pp)

rnd = Xorshift128Plus(1)
traces = [PMDPs.simulate_trace(mg, rnd) for i in 1:N]

sname = savename("traces_lp", pp_params,  "bson")
@tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces))

# traces = load(datadir("traces", sname))
# length(traces[:traces])