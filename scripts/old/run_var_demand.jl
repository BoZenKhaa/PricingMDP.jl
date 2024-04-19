using PMDPs
using PMDPs.LP
using POMDPs
using BSON, CSV
using DrWatson
using Random
using MCTS, DiscreteValueIteration
using DataFrames

using POMDPTools
using StaticArrays, Distributions # load pp

N = 3
# LP
for expected_res = 50:50:1200
    # pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5.)))
    # pp_params = Dict(pairs((nᵣ=10, c=5, T=100, expected_res=100., res_budget_μ=5.)))
    pp_params = Dict(
        pairs((
            nᵣ = 10,
            c = 40,
            T = 1000,
            expected_res = Float64(expected_res),
            res_budget_μ = 5.0,
        )),
    )
    name = "linear_problem"
    display("Evaluating $name with $pp_params")
    sname = savename("traces_lp", pp_params, "bson")
    # data = load(datadir("traces", sname))
    data = PMDPs.load_traces(datadir("traces", sname))

    # PMDPs.process_data(data, PMDPs.flatrate; N=N)
    PMDPs.process_data(data, PMDPs.hindsight; N = N)
    # PMDPs.process_data(data, PMDPs.vi; N=N)
    # PMDPs.process_data(data, PMDPs.mcts; N=N)
end
println("Done.")


for seed = 1:2
    for expected_res = 25:25:600
        pp_params = Dict(
            pairs((
                NV = 8,
                NE = 20,
                seed = seed,
                NP = 50,
                c = 10,
                T = 1000,
                expected_res = Float64(expected_res),
                res_budget_μ = 5.0,
            )),
        )
        name = "graph_problem"
        display("Evaluating $name with $pp_params,")
        sname = savename("traces_gp", pp_params, "bson")
        data = load(datadir("traces", sname))
        data = PMDPs.load_traces(datadir("traces", sname))

        # PMDPs.process_data(data, PMDPs.flatrate; N=N)
        PMDPs.process_data(data, PMDPs.hindsight; N = N)
        # PMDPs.process_data(data, PMDPs.vi; N=N)
        # PMDPs.process_data(data, PMDPs.mcts; N=N)
    end
end
