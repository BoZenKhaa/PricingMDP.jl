using PMDPs
using RandomNumbers.Xorshifts
using DrWatson
using BSON

using POMDPSimulators # load histories
using StaticArrays, Distributions # load

const N = 1000 # number of traces
# pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5.)))

# Linear instances
for expected_res in 50:50:1200
    pp_params = Dict(pairs((nᵣ=10, c=40, T=1000, expected_res=Float64(expected_res), res_budget_μ=5.)))
    name = "linear_problem"
    display("Generating $name with $pp_params")
    pp = PMDPs.linear_pp(;pp_params...)
    mg = PMDPs.PMDPg(pp)

    rnd = Xorshift128Plus(1)
    traces = [PMDPs.simulate_trace(mg, rnd) for i in 1:N]

    sname = savename("traces_lp", pp_params,  "bson")
    @tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces))
end

# Graph instances
for seed in 1:10
    for expected_res in 25:25:600
        pp_params = Dict(pairs((NV=8, NE=20,seed=seed, NP=50, c=10, T=1000, expected_res=Float64(expected_res), res_budget_μ=5.)))
        name = "graph_problem"
        display("Generating $name with $pp_params")
        pp = PMDPs.graph_pp(;pp_params...)
        mg = PMDPs.PMDPg(pp)

        rnd = Xorshift128Plus(1)
        traces = [PMDPs.simulate_trace(mg, rnd) for i in 1:N]

        sname = savename("traces_gp", pp_params,  "bson")
        @tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces))
    end
end