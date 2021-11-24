using PMDPs
using PMDPs.LP
using DrWatson

using POMDPs
using BSON, CSV
using DrWatson
using RandomNumbers.Xorshifts
using Random
using DataFrames
using StaticArrays, Distributions # load

using MCTS, DiscreteValueIteration
using POMDPSimulators # load histories
using POMDPPolicies

using LightGraphs
using GraphPlot
using Cairo, Compose

using Debugger

using TableView

include(srcdir("MDPPricing.jl"))

function prepare_traces(pp::PMDPs.PMDPProblem, pp_params::Dict, vi::Bool, name::String, N::Int64; trace_folder = "test_traces", seed = 1, verbose=false)
    mg = PMDPs.PMDPg(pp)
    rnd = Xorshift128Plus(seed)
    fname = savename("$(name)_N=$(N)", pp_params,  "bson")
    fpath = datadir(trace_folder, fname)
    
    if isfile(fpath) 
        data = PMDPs.load_traces(fpath)
        verbose ? println("Loading $fpath") : nothing
    else
        traces = [PMDPs.simulate_trace(mg, rnd) for i in 1:N]
        data =  @dict(name, pp, pp_params, traces, vi)
        @tagsave(fpath, data)   
        verbose ? println("Saving $fpath") : nothing   
    end
    return data
end

"""
Get input data
"""

problems = get_fast_benchmarks()
inputs = [prepare_traces(pp, params, vi, name, 100; verbose=true) for (pp, params, vi, name) in problems[1:end] ]


"""
Evaluate
"""
N_sim = 3

dpw_solver_params = (;depth=50, 
    exploration_constant=40.0, max_time=1.,
    enable_state_pw = false, 
    keep_tree=true, show_progress=false, rng=Xorshift128Plus())

mcts_solver_params = (;depth=50, 
    exploration_constant=40.0, max_time=1.,
    rng=Xorshift128Plus())

# pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5., objective=objective)))
# name = "linear_problem"
out_folder="test"

for (i, data) in enumerate(inputs)
    print("\t Data $i - Evaluating $(data[:name]) with $(data[:pp_params]): ")
    print("flatrate..."); PMDPs.process_data(data, PMDPs.flatrate; folder=out_folder, N=N_sim)
    print("hindsight..."); PMDPs.process_data(data, PMDPs.hindsight; folder=out_folder, N=N_sim)
    print("vi..."); data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder=out_folder, N=N_sim)
    # print("vi..."); data[:vi] && PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N_sim)

    print("dpw..."); PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N_sim, 
            method_info="dpw_$(savename(dpw_solver_params))", solver=DPWSolver(;dpw_solver_params...))
    println("mcts..."); PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N_sim, 
            method_info="vanilla_$(savename(mcts_solver_params))", solver=MCTSSolver(;mcts_solver_params...))
end
println("LP Done.")

"""
Collect results
"""

results = folder_report(datadir("results", "test", "linear_problem"); raw_result_array=true);
agg_res = format_result_table(results.results; N=N_sim)

# using WebIO
vscodedisplay(agg_res)

results.raw[1]