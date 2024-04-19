using PMDPs
using PMDPs.LP
using DrWatson

using POMDPs
using BSON, CSV
using DrWatson
using Random
using DataFrames
using StaticArrays, Distributions # load

using MCTS, DiscreteValueIteration
using POMDPTools # load histories

using LightGraphs
using GraphPlot
using Cairo, Compose

using Debugger

using TableView

include(srcdir("MDPPricing.jl"))


objective = :revenue
# pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5., objective=objective)))
pp_params = Dict(
    pairs((
        nᵣ = 5,
        c = 3,
        T = 30,
        expected_res = 30.0,
        res_budget_μ = 5.0,
        objective = objective,
    )),
) # VI runs
# pp_params =  Dict(pairs((nᵣ=6, c=3, T=30, expected_res=36., res_budget_μ=5., 
#                    objective=objective))) # VI does not run 
name = "linear_problem"

"""
Prepare traces
"""

N_individ = 10
display("Generating $name with $pp_params")

pp = PMDPs.linear_pp(; pp_params...)
mg = PMDPs.PMDPg(pp)

rng = Xoshiro(1)
traces = [PMDPs.simulate_trace(mg, rng) for i = 1:N_individ]

sname = savename("traces_lp", pp_params, "bson")
@tagsave(datadir("test_traces", sname), @dict(name, pp, pp_params, traces))

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

# pp_params = Dict(pairs((nᵣ=3, c=3, T=10, expected_res=3., res_budget_μ=5., objective=objective)))
# name = "linear_problem"
out_folder = "test"

display("Evaluating $name with $pp_params")
sname = savename("traces_lp", pp_params, "bson")
# data = load(datadir("traces", sname))
# data = load(datadir("test_traces", sname))
data = PMDPs.load_traces(datadir("test_traces", sname))

# PMDPs.process_data(data, PMDPs.flatrate; folder=out_folder, N=N_sim)
# PMDPs.process_data(data, PMDPs.hindsight; folder=out_folder, N=N_sim)
PMDPs.process_data(data, PMDPs.vi; folder = out_folder, N = N_sim)
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
