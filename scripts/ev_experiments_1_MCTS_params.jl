using PMDPs
using PMDPs.LP
using DrWatson
using Random
using MCTS
using DiscreteValueIteration

import Base.show

using Plots
using Distributions
using ProgressMeter


using POMDPs
using DataFrames
using CSV
using FilePaths
using FilePathsBase; using FilePathsBase: /
using YAML
using JLD2
# using FileIO

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
# pp = PMDPs.linear_pp(2; c = 2, T = 8)

"""
PREPARE PROBLEM AND TRACES
"""

OUT_FOLDER = "ev_experiments"
PP_NAME = "single_day_cs_pp_testing_MCTS"
pp=nothing

inputs = []
# res_range = range(6, 6)
res_range = [6,7]
# T_range =  [[3*18, 4*10]; [5,6,7,8,9,10,12, 14, 16, 18, 20, 24].*8]
T_nᵣ_multiplier = ones(length(res_range))
for (i, nᵣ) in enumerate(res_range)
    while true
        T = Int64(nᵣ * T_nᵣ_multiplier[i])
        pp_params = Dict(pairs((
            nᵣ=nᵣ,
            c=3,
            T=T,
            demand_scaling_parameter=2 * nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
            res_budget_μ=24.0 / nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
            objective=PMDPs.REVENUE,
        )))
        println("$(i): nᵣ = $(nᵣ)")
        try
            pp_constructor = PMDPs.single_day_cs_pp
            pp = pp_constructor(; pp_params...)
            pp_hash = string(hash(pp_params))
            problem_dir = cwd() / "data"/ "inputs"/string(pp_constructor)/"nodes_$(nᵣ)"/"timesteps_$T/instance_$(pp_hash)"
            mkpath(problem_dir)
            YAML.write_file(string(problem_dir / "params.yaml"), pp_params)
            JLD2.save(string(problem_dir / "pp.jld2"), "pp", pp, 
                                "constructor", pp_constructor, 
                                "params", pp_params)

        catch e
            if isa(e, AssertionError)
                # println("Error: ", e)
                println("$(i): low multipler $(T_nᵣ_multiplier[i]) for nᵣ $(nᵣ)")
                T_nᵣ_multiplier[i] += 1
                continue
            else
                throw(e)
            end
        end
        break
    end
end
println("The multipliers for getting T are $(T_nᵣ_multiplier)")

JLD2.load("data/inputs/single_day_cs_pp/nodes_6/timesteps_42/pp.jld2")

T_range = res_range .* 7
pp_var_params = collect(zip(T_range, res_range))
Threads.@threads for (T, nᵣ) in pp_var_params
    pp_params = Dict(pairs((
        nᵣ=nᵣ,
        c=3,
        T=T,
        demand_scaling_parameter=2 * nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
        res_budget_μ=24.0 / nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
        objective=PMDPs.REVENUE,
    )))
    println("nᵣ = ", nᵣ)
    pp = PMDPs.single_day_cs_pp(; pp_params...)
    PMDPs.statespace_size(pp)

    vi = true
    name = PP_NAME
    n_traces = 1000

    # mg = PMDPs.PMDPg(pp)
    # me = PMDPs.PMDPe(pp)
    # tr = PMDPs.simulate_trace(PMDPs.PMDPg(pp),RNG(1))

    push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder=OUT_FOLDER, seed=1))
    # upp_params = deepcopy(pp_params)
    # upp_params[:objective]=:utilization
    # push!(inputs, PMDPs.prepare_traces(pp, upp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1))
end

"""
PREPARE SOLVERS AND RUN EXPERIMENTS
"""
SAVE_SIM_HISTORY = true

params_dpw = Dict(
    pairs((
        depth=50,
        exploration_constant=40.0,
        enable_state_pw=false,
        keep_tree=true,
        show_progress=false,
        rng=RNG(1),
    )),
)

params_classical_MCTS = Dict(
    pairs((
        depth=3,
        exploration_constant=1.0,
        n_iterations=100,
        reuse_tree=true,
        rng=RNG(1),
    )),
)
# mcts_params_note = "_unlimited_rollout"
# function MCTS.rollout(estimator::MCTS.SolvedRolloutEstimator, mdp::MDP, s, d::Int)
#     sim = RolloutSimulator(;estimator.rng, eps=nothing, max_steps=nothing)
#     POMDPs.simulate(sim, mdp, estimator.policy, s)
# end

MCTSSolver(; params_classical_MCTS...)

N_traces = 100
e_inputs = collect(enumerate(inputs[1:end]))

for (i, data) in e_inputs
    println("hindsight...")
    PMDPs.process_data(data, PMDPs.hindsight; folder = OUT_FOLDER, N = N_traces, save_simhistory=SAVE_SIM_HISTORY)
end

for (i, data) in e_inputs
    if PMDPs.n_resources(data[:pp])<=6
        println("vi...")
        data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder = OUT_FOLDER, N = N_traces, save_simhistory=SAVE_SIM_HISTORY)
    end
end

# Threads.@threads 
for (i, orig_data) in e_inputs
    data = deepcopy(orig_data)
    # println("\t Data - Evaluating $(data[:name]) with $(data[:pp_params]): ")
    println("flatrate...")
    PMDPs.process_data(data, PMDPs.flatrate; folder = OUT_FOLDER, N = N_traces, save_simhistory=SAVE_SIM_HISTORY)
end



for (i, orig_data) in e_inputs

    # phase 1
    # depths = [1,2,3,7,10,12,20]
    # ecs = [1., 3., 5., 10.]
    # n_iter = [50,200,300,400,600, 800, 1000]

    # phase 2
    # depths = [1, 2, 3, 4, 5, 6, 7, 10]
    # ecs = [7., 9., 15.]
    # n_iter = [400, 600, 800, 1000, 1500]

    # phase 3 - good choice
    depths = [4,]
    ecs = [25., ]
    n_iter = [1500,]


    params = collect(Base.product(depths, ecs, n_iter))

    Threads.@threads for (depth, ec, n_iter) in params

        params_classical_MCTS = Dict(
            pairs((
                depth=depth,
                exploration_constant=ec,
                n_iterations=n_iter,
                reuse_tree=true,
                rng=RNG(1),
            )),
        )

        data = deepcopy(orig_data)

        # println("dpw...")
        # PMDPs.process_data(
        #     data,
        #     PMDPs.mcts;
        #     folder = OUT_FOLDER,
        #     N = N_traces,
        #     solver_params = params_dpw,
        #     method_info = "dpw_$(savename(params_dpw))",
        #     solver = DPWSolver(; params_dpw...),
        # )

        println("mcts_", savename(params_classical_MCTS))

        PMDPs.process_data(
            data,
            PMDPs.mcts;
            folder=OUT_FOLDER,
            N=N_traces,
            # method_info = "vanilla_$(hash(params_classical_MCTS))",
            method_info="vanilla_$(savename(params_classical_MCTS))",
            solver_params=params_classical_MCTS,
            solver=MCTSSolver(; params_classical_MCTS...), save_simhistory=SAVE_SIM_HISTORY
        )
    end
end

"""
ANALYZE AND PLOT RESULTS
"""

# results, raw = MDPPricing.folder_report(datadir(OUT_FOLDER, "results", PP_NAME); raw_result_array=true)

# df = results

# agg_res = MDPPricing.format_result_table(df, N=N_traces)
# # grps = groupby(df, [:method, :objective])
# # grp = grps[1]

# using Plots

# begin
#     plot(legend=:outertopleft)
#     for method in ["flatrate", "vi", "hindsight"]
#         res = filter(:method => m -> startswith(m, method), agg_res)
#         hline!(res.mean_r, label=method, line=(:dash, 4))
#     end


#     res = filter(:method => m -> startswith(m, "mcts"), agg_res)
#     resp = hcat(res, DataFrame(res.solver_params))

#     var_cols = [:exploration_constant, :n_iterations, :depth]
#     gr_cols = [var_cols[1], var_cols[3]]
#     plot_col = var_cols[2]

#     sort!(resp, var_cols, rev=true)
#     for gr in groupby(resp, gr_cols)
#         plot!(gr[!, plot_col], gr.mean_r,
#             label="$(string(gr_cols[1])[1]):$(gr[1, gr_cols[1]])-$(string(gr_cols[2])[1]):$(gr[1, gr_cols[2]])",
#             xlabel=plot_col,
#             ylabel="mean_r")
#     end
#     plot!()
# end

# res = filter(:method => m -> startswith(m, "mcts"), agg_res)
# resp = hcat(res, DataFrame(res.solver_params))
# CSV.write("notebooks/PlotlyJS/mcts_params_results.csv", resp)
# # Continue in notebook (notebooks/PlotlyJS)