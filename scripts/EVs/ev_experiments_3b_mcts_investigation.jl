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


using ProgressMeter

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
rng=RNG(426380)
Base.show(io::IO, rng::Xorshift1024Plus) = print(io, "Xorshift1024Plus")

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

Categorical(start_times.weights/sum(start_times.weights))
Categorical(charging_durations.weights/sum(charging_durations.weights))

start_times_d = DiscreteNonParametric(
    start_times.edges[1][1:end-1].+0.5,
    start_times.weights/sum(start_times.weights))

charging_durations_d = DiscreteNonParametric(
    charging_durations.edges[1][1:end-1].+1/6/2,
    charging_durations.weights/sum(charging_durations.weights))


# Try fitting distributions
begin # OK
    start_times_nd = truncated(fit_mle(Normal, df.start_hour), 0,24)
    # plot(start_times_d)
    # plot!(start_times_nd)
end

begin # Not very good
    charging_durations_ed = truncated(fit_mle(Gamma, df.total_duration_h), 0,8)
    # plot(charging_durations_d)
    # plot!(charging_durations_ed)
end

"""
FIGURE OUT NUMBER OF TIMESTEPS FOR PROBLEMS
"""
# nᵣ = 24
nᵣ = 48
#nᵣ = 72
# nᵣ = 96

expected_res_range = [0.5*nᵣ, 1*nᵣ, 1.5*nᵣ, 2*nᵣ, 2.5*nᵣ, 3*nᵣ, 3.5*nᵣ]
expected_res_range./(3*nᵣ)

T_multipliers = ones(length(expected_res_range))
for (i, expected_res) in enumerate(expected_res_range)
    while true
        # pp_params = get_pp_params(expected_res)
        pp_params = Dict(pairs((
                nᵣ = nᵣ,
                c = 3,
                T = Int64(expected_res*T_multipliers[i]),
                expected_res = expected_res, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
                res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
                objective = :utilization,
            )))
        # println("$(i): nᵣ = $(nᵣ)")
        try
            pp = PMDPs.single_day_cs_pp(start_times_d, charging_durations_d;pp_params...)
        catch e
            if isa(e, AssertionError)
                # Sprintln("Error: ", e)
                # println("$(i): low multipler $(T_multipliers[i]) for nᵣ $(nᵣ)")
                T_multipliers[i]+=1
                continue
            else
                throw(e)
            end
        end
        break
    end
end
println("The multipliers for getting T are $(T_multipliers) -> $(maximum(T_multipliers))")
T_multiplier = maximum(T_multipliers)

"""
PREPARE PROBLEM AND TRACES
"""

OUT_FOLDER = "ev_experiments"

inputs = []
PP_NAME = "cs_deggendorf_data_driven_$(nᵣ)"

# Threads.@threads 
for expected_res in expected_res_range
    # println("\n===Running expected res: $(expected_res)")
    pp_params = Dict(pairs((
            nᵣ = nᵣ,
            c = 3,
            T = Int64(expected_res*T_multiplier),
            expected_res = expected_res, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
            res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
            objective = :revenue,
        )))
    # PMDPs.statespace_size(pp)
        
    vi = false
    name = PP_NAME
    n_traces = 1000
    
    # mg = PMDPs.PMDPg(pp)
    # me = PMDPs.PMDPe(pp)
    
    # tr = PMDPs.simulate_trace(PMDPs.PMDPg(pp),RNG(1))
    pp = PMDPs.single_day_cs_pp(start_times_d, charging_durations_d; pp_params...)
    push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=8888, save=true))

    upp_params = deepcopy(pp_params)
    upp_params[:objective]=:utilization
    upp = PMDPs.single_day_cs_pp(;upp_params...)
    push!(inputs, PMDPs.prepare_traces(upp, upp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1))
end

"""
PREPARE SOLVERS AND RUN EXPERIMENTS
"""

# params_dpw = Dict(
#     pairs((
#         depth = 50,
#         exploration_constant = 40.0,
#         enable_state_pw = false,
#         keep_tree = true,
#         show_progress = false,
#         rng = RNG(1),
#     )),
# )


params_classical_MCTS = Dict(
    pairs((
        depth = 3,
        exploration_constant = 1.0,
        n_iterations = 1000,
        reuse_tree = true,
        rng = RNG(1),
    )),
)


N_traces=10
e_inputs = collect(enumerate(inputs[1:end]))

println("Total of inputs: $(length(e_inputs))")

n_threads = Threads.nthreads()
# n_threads=3
# e_inputs
reordered_inputs = typeof(e_inputs[1])[]
n_jobs_per_thread = ceil(length(e_inputs)/n_threads)
for j in 1:n_jobs_per_thread
    for i in 1:length(e_inputs)
        if i%n_jobs_per_thread==(j-1)
            input = e_inputs[i]
            push!(reordered_inputs, input)
        end
    end
end
println("Total of reordered inputs: $(length(reordered_inputs)):")
for (i, input) in reordered_inputs
    println("\t$(i): $(input[:pp_params])")
end

# p=Progress(length(e_inputs)*N_traces, desc="All MCTS:", color=:red)

# Threads.@threads for (i, orig_data) in reordered_inputs
#     # data = deepcopy(orig_data)
#     data = orig_data

#     solver = MCTSSolver(;params_classical_MCTS...)
#     println("mcts, data-$i: \n\t problem: $(data[:pp_params]) \n\t solver: $(solver)")
#     PMDPs.process_data(
#         data,
#         PMDPs.mcts;
#         folder = OUT_FOLDER,
#         n = 1,
#         N = N_traces,
#         method_info = "vanilla_$(savename(params_classical_MCTS))",
#         solver = solver,
#         rng=rng,
#         p=p,
#     )
# end


for (i, data) in e_inputs
    println("flatrate...")
    PMDPs.process_data(data, PMDPs.flatrate; folder = OUT_FOLDER, N = N_traces,  train_range=1:round(Int64, N_traces/100*25), rng=rng)
end

for (i, data) in e_inputs
    """
    To run in parallel with suppressed output
    https://stackoverflow.com/questions/64844626/julia-1-5-2-suppressing-gurobi-academic-license-in-parallel
    """
    println("hindsight...")
    PMDPs.process_data(data, PMDPs.hindsight; folder = OUT_FOLDER, N = N_traces, rng=rng)
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