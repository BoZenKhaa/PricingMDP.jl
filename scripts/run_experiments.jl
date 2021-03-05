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

using LightGraphs
using GraphPlot
using Cairo, Compose

using Debugger

using TableView

include(srcdir("MDPPricing.jl"))

function prepare_traces(pp::PMDPs.PMDPProblem, pp_params::Dict, name::String, N::Int64; trace_folder = "test_traces", seed = 1, verbose=false)
    mg = PMDPs.PMDPg(pp)
    rnd = Xorshift128Plus(seed)
    fname = savename("$(name)_N=$(N)", pp_params,  "bson")
    fpath = datadir(trace_folder, fname)
    
    if isfile(fpath) 
        data = PMDPs.load_traces(fpath)
        verbose ? println("Loading $fpath") : nothing
    else
        traces = [PMDPs.simulate_trace(mg, rnd) for i in 1:N]
        data =  @dict(name, pp, pp_params, traces)
        @tagsave(fpath, data)   
        verbose ? println("Saving $fpath") : nothing   
    end
    return data
end

problems = get_fast_benchmarks()

for (pp, params, name) in problems[1:end]
    prepare_traces(pp, params, name, 10; verbose=true)
end

"""
Prepare traces
"""

N_individ=10
display("Generating $name with $pp_params")

pp = PMDPs.linear_pp(;pp_params...)


    # jldopen(datadir("test_traces", sname), "w") do file
#     addrequire(file, PMDPs)
#     write(file, "data", @strdict(name, pp_params))
# end

# PMDPs.State{3}


# @save(datadir("test_traces", sname),  @strdict(name, pp, pp_params, traces))
# load(datadir("test_traces", sname))

"""
Evaluate
"""
N_sim = 10

dpw_solver = DPWSolver(;depth=50, 
exploration_constant=40.0, max_time=1.,
                enable_state_pw = false, 
                keep_tree=true, show_progress=false, rng=Xorshift128Plus())

                mcts_solver = MCTSSolver(;depth=50, 
                exploration_constant=40.0, max_time=1.,
                rng=Xorshift128Plus())
                
# pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5., objective=objective)))
# name = "linear_problem"
out_folder="test"

display("Evaluating $name with $pp_params")
sname = savename("traces_lp", pp_params,  "bson")
# data = load(datadir("traces", sname))
# data = load(datadir("test_traces", sname))

# PMDPs.process_data(data, PMDPs.flatrate; folder=out_folder, N=N_sim)
# PMDPs.process_data(data, PMDPs.hindsight; folder=out_folder, N=N_sim)
PMDPs.process_data(data, PMDPs.vi; folder=out_folder, N=N_sim)
# PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N_sim)

# PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N_sim, method_info="dpw", mcts_solver=dpw_solver)
# PMDPs.process_data(data, PMDPs.mcts; folder=out_folder, N=N_sim, method_info="vanilla", mcts_solver=mcts_solver)
println("LP Done.")

"""
Collect results
"""

# results = folder_report(datadir("results", "test", "linear_problem"))
# agg_res = format_result_table(results)

# using WebIO
# vscodedisplay(agg_res)