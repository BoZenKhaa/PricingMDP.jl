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

N = 10

dpw_solver = DPWSolver(;depth=50, 
                exploration_constant=40.0, max_time=1.,
                enable_state_pw = false, 
                keep_tree=true, show_progress=false, rng=Xorshift128Plus())

mcts_solver = MCTSSolver(;depth=50, 
                exploration_constant=40.0, max_time=1.,
                rng=Xorshift128Plus())

# ------ LP ------------
pps = [
    Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5.))),
    Dict(pairs((nᵣ=10, c=5, T=100, expected_res=100., res_budget_μ=5.))),
    Dict(pairs((nᵣ=10, c=40, T=1000, expected_res=Float64(800), res_budget_μ=5.))),
    Dict(pairs((nᵣ=50, c=40, T=1000, expected_res=Float64(4000), res_budget_μ=5.)))
]
name = "linear_problem"
out_folder="individual"

for pp_params in pps
    display("Evaluating $name with $pp_params")
    sname = savename("traces_lp", pp_params,  "bson")
    # data = load(datadir("traces", sname))
    data = PMDPs.load_traces(datadir("traces", sname))

    PMDPs.process_data(data, PMDPs.flatrate; folder=out_folder, N=N)
    PMDPs.process_data(data, PMDPs.hindsight; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.vi; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N)

    PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N, method_info="dpw", dpw_solver=mcts_solver)
    PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N, method_info="vanilla", mcts_solver=mcts_solver)
end
println("LP Done.")



# ----------- Graph ----------
seed = 12
gpps = [
    Dict(pairs((NV=5, NE=8, seed=1, NP=20, c=5, T=100, expected_res=Float64(80), res_budget_μ=5.))), 
    # Dict(pairs((NV=8, NE=20, seed=1, NP=50, c=10, T=1000, expected_res=Float64(400), res_budget_μ=5.))),
    # Dict(pairs((NV=15, NE=30, seed=1, NP=100, c=10, T=1000, expected_res=Float64(600), res_budget_μ=5.))),
    # Dict(pairs((NV=30, NE=45, seed=1, NP=100, c=10, T=1000, expected_res=Float64(900), res_budget_μ=5.)))
]
name = "graph_problem"
out_folder="individual"
for pp_params in gpps
    name = "graph_problem"
    display("Evaluating $name with $pp_params,")
    sname = savename("traces_gp", pp_params,  "bson")
    data = load(datadir("traces", sname))
    data = PMDPs.load_traces(datadir("traces", sname))

    # PMDPs.process_data(data, PMDPs.flatrate; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.hindsight; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.vi; N=N)
    PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N)
    # PMDPs.process_data(data, PMDPs.mcts; N=N)
    # PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N, method_info="dpw", dpw_solver=mcts_solver)
    # PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N, method_info="vanilla", mcts_solver=mcts_solver)
end