using PMDPs
using PMDPs.LP
using DrWatson
using RandomNumbers.Xorshifts
using MCTS
using POMDPSimulators
using POMDPPolicies
using DiscreteValueIteration

using Formatting

import Base.show

using Plots
using Distributions
using ProgressMeter


using POMDPs
using DataFrames

# function Base.show(io::IO, ::MIME"text/plain", trace::SimHistory)
#     for step in trace
#         print(io, step.s)
#         action = step.a
#         budget = step.info.b
#         printfmt(io, " b:{: 6.2f}", budget)
#         printfmt(io, " a:{: 6.2f}", action)

#         outcome, color = PMDPs.user_buy(action, budget) ? ("buy", :green) : ("not", :red)
#         print(" -> ")
#         printstyled(io, "$(outcome)"; color=color)
#         print("\t")
#         print(io, step.s)
#         print(io, "\n")
#     end
# end

RND = Xorshift1024Plus

include(srcdir("MDPPricing.jl"))


"""
# EV problem

Resources are the discretized timeslots during the day.
Capacity in a timeslot is the number of available charging points.
T is the number of timesteps. 
"""

"""
# Linear problem
A placeholder before I fugure out the experiments
"""
 # pp = PMDPs.linear_pp(2; c = 2, T = 8)
 
"""
PREPARE PROBLEM AND TRACES
"""

pp_params = Dict(pairs((
        nᵣ = 3,
        c = 1,
        T = 10,
        expected_res = 6.0,
        res_budget_μ = 5.0,
        objective = :revenue,
    )))

pp = PMDPs.linear_pp(;pp_params...)

vi = true
name = "test_ev_problem"
n_traces = 5

# mg = PMDPs.PMDPg(pp)
# me = PMDPs.PMDPe(pp)
inputs = [  PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, trace_folder = "ev_traces", seed=1),
            PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, trace_folder = "ev_traces", seed=1),]

"""
PREPARE SOLVERS AND RUN EXPERIMENTS
"""

params_dpw = Dict(
    pairs((
        depth = 50,
        exploration_constant = 40.0,
        enable_state_pw = false,
        keep_tree = true,
        show_progress = false,
        rng = RND(1),
    )),
)

params_classical_MCTS = Dict(
    pairs((
        depth = 15,
        exploration_constant = 40.0,
        reuse_tree = true,
        rng = RND(1),
    )),
)

out_folder= "ev_results"
N_traces=n_traces


for (i, data) in enumerate(inputs)
    print("\t Data - Evaluating $(data[:name]) with $(data[:pp_params]): ")
    print("flatrate...")
    PMDPs.process_data(data, PMDPs.flatrate; folder = out_folder, N = N_traces)
    print("hindsight...")
    PMDPs.process_data(data, PMDPs.hindsight; folder = out_folder, N = N_traces)
    print("vi...")
    data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder = out_folder, N = N_traces)
    # print("vi..."); data[:vi] && PMDPs.process_data(data, PMDPs.fhvi; folder=out_folder, N=N_sim)

    print("dpw...")
    PMDPs.process_data(
        data,
        PMDPs.mcts;
        folder = out_folder,
        N = N_traces,
        method_info = "dpw_$(savename(params_dpw))",
        solver = DPWSolver(; params_dpw...),
    )

    println("mcts...")
    PMDPs.process_data(
        data,
        PMDPs.mcts;
        folder = out_folder,
        N = N_traces,
        method_info = "vanilla_$(savename(params_classical_MCTS))",
        solver = MCTSSolver(;params_classical_MCTS...),
    )
end

"""
ANALYZE RESULTS
"""

results = folder_report(datadir("results", "ev_results", "test_ev_problem"); raw_result_array = true)

agg_res = format_result_table(results.results, N=N_traces)