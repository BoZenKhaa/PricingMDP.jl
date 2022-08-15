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

RNG = Xorshift1024Plus

include(srcdir("MDPPricing.jl"))


"""
LOAD DATA
(see notebook for details)
"""

using CSV
using Statistics
using StatsBase
using StatsPlots


df = DataFrame(CSV.File(datadir("cs_data", "deggendorf_ackerloh_charging.csv")))

bins = 0:1/6:8 # 10 minute resolution, capped at 8 hours
charging_durations = fit(Histogram, df.total_duration_h, bins)
charging_durations.weights
# plot(charging_durations)

bins = 0:1:24 # 1 hour resolution
start_times = fit(Histogram, df.start_hour, bins)
start_times.weights
# plot(start_times)

# try turning histogram into distribution

Categorical(start_times.weights / sum(start_times.weights))
Categorical(charging_durations.weights / sum(charging_durations.weights))

start_times_d = DiscreteNonParametric(
    start_times.edges[1][1:end-1] .+ 0.5,
    start_times.weights / sum(start_times.weights))

charging_durations_d = DiscreteNonParametric(
    charging_durations.edges[1][1:end-1] .+ 1 / 6 / 2,
    charging_durations.weights / sum(charging_durations.weights))


# Try fitting distributions
begin # OK
    start_times_nd = truncated(fit_mle(Normal, df.start_hour), 0, 24)
    # plot(start_times_d)
    # plot!(start_times_nd)
end

begin # Not very good
    charging_durations_ed = truncated(fit_mle(Gamma, df.total_duration_h), 0, 8)
    # plot(charging_durations_d)
    # plot!(charging_durations_ed)
end

"""
PREPARE PROBLEM AND TRACES
"""

OUT_FOLDER = "ev_experiments"

inputs = []
PP_NAME = "cs_deggendorf_data_driven"
nᵣ = 48
# Threads.@threads 
for expected_res in [0.5 * nᵣ, 1 * nᵣ, 1.5 * nᵣ, 2 * nᵣ, 2.5 * nᵣ, 3 * nᵣ, 3.5 * nᵣ, 4 * nᵣ]
    println("\n===Running expected res: $(expected_res)")
    pp_params = Dict(pairs((
        nᵣ = nᵣ,
        c = 3,
        T = Int64(expected_res * 8),
        expected_res = expected_res, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
        res_budget_μ = 1.0, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
        objective = :revenue,
    )))
    pp = PMDPs.single_day_cs_pp(start_times_d, charging_durations_d; pp_params...)
    PMDPs.statespace_size(pp)

    vi = false
    name = PP_NAME
    n_traces = 1000

    # mg = PMDPs.PMDPg(pp)
    # me = PMDPs.PMDPe(pp)

    # tr = PMDPs.simulate_trace(PMDPs.PMDPg(pp),RNG(1))
    push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose = true, folder = OUT_FOLDER, seed = 1, save = true))
    # pp_params[:objective]=:utilization
    # push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1))
end

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
        rng = RNG(1),
    )),
)

params_classical_MCTS = Dict(
    pairs((
        depth = 15,
        exploration_constant = 40.0,
        reuse_tree = true,
        rng = RNG(1),
    )),
)


N_traces = 100

e_inputs = collect(enumerate(inputs[1:end]))

for (i, orig_data) in e_inputs
    """
    To run in parallel with suppressed output
    https://stackoverflow.com/questions/64844626/julia-1-5-2-suppressing-gurobi-academic-license-in-parallel
    """
    println("$(i) - hindsight...")
    PMDPs.process_data(data, PMDPs.hindsight; folder = OUT_FOLDER, N = N_traces)
    println("$(i) - hindsight... Done")
end

# Threads.@threads 
for (i, orig_data) in e_inputs
    data = deepcopy(orig_data)
    # println("\t Data - Evaluating $(data[:name]) with $(data[:pp_params]): ")
    # println("flatrate...")
    # PMDPs.process_data(data, PMDPs.flatrate; folder = OUT_FOLDER, N = N_traces)

    # println("vi...")
    # if PMDPs.n_resources(data[:pp])<=6
    #     data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder = OUT_FOLDER, N = N_traces)
    # end

    # println("dpw...")
    # PMDPs.process_data(
    #     data,
    #     PMDPs.mcts;
    #     folder = OUT_FOLDER,
    #     N = N_traces,
    #     method_info = "dpw_$(savename(params_dpw))",
    #     solver = DPWSolver(; params_dpw...),
    # )

    # println("mcts...")
    # PMDPs.process_data(
    #     data,
    #     PMDPs.mcts;
    #     folder = OUT_FOLDER,
    #     N = N_traces,
    #     method_info = "vanilla_$(savename(params_classical_MCTS))",
    #     solver = MCTSSolver(;params_classical_MCTS...),
    # )
end

# """
# ANALYZE AND PLOT RESULTS
# """
# results, raw = folder_report(datadir("results", "ev_results", PP_NAME); raw_result_array = true)

# df = results.results
# df

# # agg_res = format_result_table(results.results, N=N_traces)
# grps = groupby(df, [:method, :objective])
# grp = grps[1]

# plot()
# for grp in grps
#     label = grp.method[1][1:min(10, length(grp.method[1]))]
#     plot!(grp.expected_res, grp.mean_r; label=grp.method[1][1:3] )
# end
# plot!()

# print(sort(unique([String(v.name) for v in methodswith(DataFrame)])))
# DataFrames

# methods()