using PMDPs
using PMDPs.LP
using POMDPs
using BSON, CSV
using DrWatson
using Random
using MCTS, DiscreteValueIteration
using DataFrames

using POMDPTools
using Distributions # load pp

N = 10

dpw_solver = DPWSolver(;
    depth = 50,
    exploration_constant = 40.0,
    max_time = 1.0,
    enable_state_pw = false,
    keep_tree = true,
    show_progress = false,
    rng = Xoshiro(),
)

mcts_solver = MCTSSolver(;
    depth = 50,
    exploration_constant = 40.0,
    max_time = 1.0,
    rng = Xoshiro(),
)

"""
 ------ BUS ------------
"""
name = "bus_problem"
out_folder = "individual"

display("Evaluating $name")
# sname = string("traces_bus_T=1000_c=55_expected_requests=80_nᵣ=3_objective=revenue_res_budget_μ=5",  ".bson")
sname = string(
    "traces_bus_T=2000_c=55_expected_requests=160_nᵣ=3_objective=revenue_res_budget_μ=5",
    ".bson",
)
# data = load(datadir("traces", sname))
data = PMDPs.load_traces(datadir("traces", sname))

PMDPs.process_data(data, PMDPs.flatrate; folder = out_folder, N = N)
PMDPs.process_data(data, PMDPs.hindsight; folder = out_folder, N = N)
# PMDPs.process_data(data, PMDPs.vi; folder=out_folder, N=N)
# PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N)
PMDPs.process_data(
    data,
    PMDPs.mcts;
    folder = out_folder,
    N = N,
    method_info = "dpw",
    mcts_solver = dpw_solver,
)
PMDPs.process_data(
    data,
    PMDPs.mcts;
    folder = out_folder,
    N = N,
    method_info = "vanilla",
    mcts_solver = mcts_solver,
)

println("$name Done.")


N = 10
"""
 ------ LP ------------
"""
pps = [
    # Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5.))),
    # # Dict(pairs((nᵣ=6, c=5, T=100, expected_res=60., res_budget_μ=5.))),
    # Dict(pairs((nᵣ=10, c=5, T=100, expected_res=100., res_budget_μ=5.))),
    # Dict(pairs((nᵣ=10, c=40, T=1000, expected_res=Float64(800), res_budget_μ=5.))),
    # Dict(pairs((nᵣ=50, c=40, T=1000, expected_res=Float64(4000), res_budget_μ=5.))), 
    Dict(
        pairs((
            nᵣ = 3,
            c = 3,
            T = 10,
            expected_res = 3.0,
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    # Dict(pairs((nᵣ=6, c=5, T=100, expected_res=60., res_budget_μ=5., objective=:utilization))),
    Dict(
        pairs((
            nᵣ = 10,
            c = 5,
            T = 100,
            expected_res = 100.0,
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            nᵣ = 10,
            c = 40,
            T = 1000,
            expected_res = Float64(800),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            nᵣ = 50,
            c = 40,
            T = 1000,
            expected_res = Float64(4000),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
]
name = "linear_problem"
out_folder = "individual"

for pp_params in pps
    display("Evaluating $name with $pp_params")
    sname = savename("traces_lp", pp_params, "bson")
    # data = load(datadir("traces", sname))
    data = PMDPs.load_traces(datadir("traces", sname))

    # PMDPs.process_data(data, PMDPs.flatrate; folder=out_folder, N=N)
    PMDPs.process_data(data, PMDPs.hindsight; folder = out_folder, N = N)
    # PMDPs.process_data(data, PMDPs.vi; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N)

    # PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N, method_info="dpw", mcts_solver=dpw_solver)
    # PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N, method_info="vanilla", mcts_solver=mcts_solver)
end
println("LP Done.")



"""
 ------ Graph ------------
"""
seed = 12
gpps = [
    # Dict(pairs((NV=5, NE=8, seed=1, NP=20, c=5, T=100, expected_res=Float64(80), res_budget_μ=5.))), 
    # Dict(pairs((NV=8, NE=20, seed=1, NP=50, c=10, T=1000, expected_res=Float64(400), res_budget_μ=5.))),
    # Dict(pairs((NV=15, NE=30, seed=1, NP=100, c=10, T=1000, expected_res=Float64(600), res_budget_μ=5.))),
    # Dict(pairs((NV=30, NE=45, seed=1, NP=100, c=10, T=1000, expected_res=Float64(900), res_budget_μ=5.)))
    Dict(
        pairs((
            NV = 5,
            NE = 8,
            seed = 1,
            NP = 20,
            c = 5,
            T = 100,
            expected_res = Float64(80),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            NV = 8,
            NE = 20,
            seed = 1,
            NP = 50,
            c = 10,
            T = 1000,
            expected_res = Float64(400),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            NV = 15,
            NE = 30,
            seed = 1,
            NP = 100,
            c = 10,
            T = 1000,
            expected_res = Float64(600),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            NV = 30,
            NE = 45,
            seed = 1,
            NP = 100,
            c = 10,
            T = 1000,
            expected_res = Float64(900),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
]
name = "graph_problem"
out_folder = "individual"
for pp_params in gpps
    name = "graph_problem"
    display("Evaluating $name with $pp_params,")
    sname = savename("traces_gp", pp_params, "bson")
    data = load(datadir("traces", sname))
    data = PMDPs.load_traces(datadir("traces", sname))

    PMDPs.process_data(data, PMDPs.flatrate; folder = out_folder, N = N)
    PMDPs.process_data(data, PMDPs.hindsight; folder = out_folder, N = N)
    # PMDPs.process_data(data, PMDPs.vi; N=N)
    # PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.mcts; N=N)
    PMDPs.process_data(
        data,
        PMDPs.mcts;
        folder = out_folder,
        N = N,
        method_info = "dpw",
        mcts_solver = dpw_solver,
    )
    PMDPs.process_data(
        data,
        PMDPs.mcts;
        folder = out_folder,
        N = N,
        method_info = "vanilla",
        mcts_solver = mcts_solver,
    )
end
