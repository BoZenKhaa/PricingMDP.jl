using PMDPs
using Random
using ProgressMeter
using DrWatson
using MCTS

RNG = Xoshiro

include(srcdir("MDPPricing.jl"))
using .MDPPricing


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

"""
PREPARE PROBLEM AND TRACES
"""

OUT_FOLDER = "ev_experiments"
PP_NAME = "single_day_const_demand_cs_pp"
OBJECTIVE = PMDPs.REVENUE
SAVE_SIM_HISTORY = true

inputs = []
println("!!!!Check me: ", PP_NAME)

# res_range = range(6, 6)
res_range = [3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24]
# T_range =  [[3*18, 4*10]; [5,6,7,8,9,10,12, 14, 16, 18, 20, 24].*8]

T_nᵣ_multiplier = ones(length(res_range))
for (i, nᵣ) in enumerate(res_range)
    while true
        pp_params = Dict(pairs((
            nᵣ=nᵣ,     
            c=3,
            T=Int64(nᵣ * T_nᵣ_multiplier[i]),
            expected_res=2 * nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
            res_budget_μ=24.0 / nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
            objective=OBJECTIVE,
        )))
        println("$(i): nᵣ = $(nᵣ)")
        try
            pp = PMDPs.single_day_cs_pp(; pp_params...)
        catch e
            if isa(e, AssertionError)
                T_nᵣ_multiplier[i] += 1
                continue
            else
                throw(e)
            end
        end
        break
    end
end
println("The multipliers for getting T are $(T_nᵣ_multiplier), setting multiplier as $(maximum(T_nᵣ_multiplier))")


T_range = res_range .* Int(maximum(T_nᵣ_multiplier))
pp_var_params = collect(zip(T_range, res_range))
Threads.@threads for (T, nᵣ) in pp_var_params
    pp_params = Dict(pairs((
        nᵣ=nᵣ,
        c=3,
        T=T,
        expected_res=2 * nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
        res_budget_μ=24.0 / nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
        objective=OBJECTIVE,
    )))
    println("nᵣ = ", nᵣ)

    vi = true
    name = PP_NAME
    n_traces = 1000

    # mg = PMDPs.PMDPg(pp)
    # me = PMDPs.PMDPe(pp)
    # tr = PMDPs.simulate_trace(PMDPs.PMDPg(pp),RNG(1))

    pp = PMDPs.single_day_cs_pp(; pp_params...)
    push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder=OUT_FOLDER, seed=1))

    upp_params = deepcopy(pp_params)
    upp_params[:objective] = PMDPs.UTILIZATION
    upp = PMDPs.single_day_cs_pp(; upp_params...)
    push!(inputs, PMDPs.prepare_traces(upp, upp_params, vi, name, n_traces; verbose=true, folder=OUT_FOLDER, seed=1))
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

# params_classical_MCTS = Dict(
#     pairs((
#         depth = 2,
#         exploration_constant = 5.0,
#         n_iterations = 800,
#         reuse_tree = true,
#         rng = RNG(1),
#     )),
# )

params_classical_MCTS = Dict(
    pairs((
        depth=4,
        exploration_constant=25.0,
        n_iterations=1500,
        reuse_tree=true,
        rng=RNG(1),
    )),
)

N_traces = 100
e_inputs = collect(enumerate(inputs[1:end]))

n_threads = Threads.nthreads()
# n_threads=3
# e_inputs
println("Total of inputs: $(length(e_inputs))")
reordered_inputs = typeof(e_inputs[1])[]
n_jobs_per_thread = ceil(length(e_inputs) / n_threads)
for j in 1:n_jobs_per_thread
    for i in 1:length(e_inputs)
        if i % n_jobs_per_thread == (j - 1)
            input = e_inputs[i]
            push!(reordered_inputs, input)
        end
    end
end
println("Total of reordered inputs: $(length(reordered_inputs)):")
for (i, input) in reordered_inputs
    println("\t$(i): $(input[:pp_params])")
end
# print(reordered_inputs)

p = Progress(length(e_inputs) * N_traces, desc="All MCTS:", color=:red)

Threads.@threads for (i, orig_data) in reordered_inputs
    data = deepcopy(orig_data)
    # data = orig_data

    # println("dpw...")
    # PMDPs.process_data(
    #     data,
    #     PMDPs.mcts;
    #     folder = OUT_FOLDER,
    #     N = N_traces,
    #     method_info = "dpw_$(savename(params_dpw))",
    #     solver = DPWSolver(; params_dpw...),
    # )

    @info "\nmcts, data-$i:\n\t$(data[:pp_params])"
    PMDPs.process_data(
        data,
        PMDPs.mcts;
        folder=OUT_FOLDER,
        N=N_traces,
        solver_params=params_classical_MCTS,
        method_info="vanilla_$(savename(params_classical_MCTS))",
        solver=MCTSSolver(; params_classical_MCTS...),
        rng=RNG(1),
        p=p, 
        save_simhistory=SAVE_SIM_HISTORY
    )
end


for (i, data) in e_inputs
    println("hindsight...")
    PMDPs.process_data(data, PMDPs.hindsight; folder=OUT_FOLDER, N=N_traces, rng=RNG(1), 
    save_simhistory=SAVE_SIM_HISTORY)
end

for (i, data) in e_inputs
    if PMDPs.n_resources(data[:pp]) <= 6
        println("vi...")
        data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder=OUT_FOLDER, N=N_traces, rng=RNG(1), 
        save_simhistory=SAVE_SIM_HISTORY)
    end
end

for (i, data) in e_inputs
    println("flatrate...")
    PMDPs.process_data(data, PMDPs.flatrate; folder=OUT_FOLDER, N=N_traces, train_range=1:round(Int64, N_traces / 100 * 25), 
    rng=RNG(1), save_simhistory=SAVE_SIM_HISTORY)
end

"""
ANALYZE AND PLOT RESULTS
"""
# results, raw = folder_report(datadir("results", "ev_results", PP_NAME); raw_result_array = true)

# df = results

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