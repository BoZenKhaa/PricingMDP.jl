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

OUT_FOLDER = "ev_experiments"

inputs = []
PP_NAME = "single_day_pp_flat"
# res_range = range(6, 6)
res_range = [3,4,5,6,7,8,9,10,12, 14, 16, 18, 20, 22, 24]
# T_range =  [[3*18, 4*10]; [5,6,7,8,9,10,12, 14, 16, 18, 20, 24].*8]

T_nᵣ_multiplier = ones(length(res_range))
for (i, nᵣ) in enumerate(res_range)
    while true
        pp_params = Dict(pairs((
                nᵣ = nᵣ,
                c = 3,
                T = Int64(nᵣ*T_nᵣ_multiplier[i]),
                expected_res = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
                res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
                objective = :revenue,
            )))
        println("$(i): nᵣ = $(nᵣ)")
        try
            pp = PMDPs.single_day_cs_pp(;pp_params...)
        catch e
            if isa(e, AssertionError)
                # println("Error: ", e)
                println("$(i): low multipler $(T_nᵣ_multiplier[i]) for nᵣ $(nᵣ)")
                T_nᵣ_multiplier[i]+=1
                continue
            else
                throw(e)
            end
        end
        break
    end
end
println("The multipliers for getting T are $(T_nᵣ_multiplier)")


T_range =  [3,4,5,6,7,8,9,10,12, 14, 16, 18, 20, 22, 24].*7
pp_var_params = collect(zip(T_range, res_range))
Threads.@threads for (T, nᵣ) in pp_var_params
    pp_params = Dict(pairs((
            nᵣ = nᵣ,
            c = 3,
            T = T,
            expected_res = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
            res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
            objective = :revenue,
        )))
    println("nᵣ = ", nᵣ)
    pp = PMDPs.single_day_cs_pp(;pp_params...)
    PMDPs.statespace_size(pp)

    vi = true
    name = PP_NAME
    n_traces =1000

    # mg = PMDPs.PMDPg(pp)
    # me = PMDPs.PMDPe(pp)
    # tr = PMDPs.simulate_trace(PMDPs.PMDPg(pp),RND(1))

    push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1))
    # upp_params = deepcopy(pp_params)
    # upp_params[:objective]=:utilization
    # push!(inputs, PMDPs.prepare_traces(pp, upp_params, vi, name, n_traces; verbose=true, folder = OUT_FOLDER, seed=1))
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
#         rng = RND(1),
#     )),
# )

params_classical_MCTS = Dict(
    pairs((
        depth = 7,
        exploration_constant = 3.0,
        n_iterations = 400,
        reuse_tree = true,
        rng = RND(1),
    )),
)

N_traces=1
e_inputs = collect(enumerate(inputs[1:end]))


i, inp = e_inputs[4]
pp = inp[:pp]
traces = inp[:traces]

rnd=RND(1)
mg = PMDPs.PMDPg(pp)
flatrate = PMDPs.get_flatrate_policy(mg, [PMDPs.simulate_trace(mg, rnd) for i = 1:5])

action(flatrate, POMDPs.initialstate(mg))
using Random

policy=flatrate
mdp=mg
requests=traces[5]
rng=RND(1)

hrpl = PMDPs.HistoryReplayer(mdp, requests)
h, stats... = @timed PMDPs.replay(hrpl, policy, rng)

# collect(h[:a])
# h[1]
# print(collect(h[:r]))
# unique(collect(h[:r]))

ne = collect([(i, s, pp.P[s.iₚ], collect(h[:r])[i]) for (i,s) in enumerate(h[:s]) if s.iₚ!=PMDPs.empty_product_id(mg)])

[t for t in ne if sum(t[3])>1]

results = PMDPs.eval_policy(mg, traces[1:2], @ntuple(flatrate), MersenneTwister(1))


# for (i, data) in e_inputs
#     println("hindsight...")
#     PMDPs.process_data(data, PMDPs.hindsight; folder = OUT_FOLDER, N = N_traces)
# end


# Threads.@threads for (i, orig_data) in e_inputs
#     data = deepcopy(orig_data)
#     println("\t Data - Evaluating $(data[:name]) with $(data[:pp_params]): ")
    
#     println("flatrate...")
        # PMDPs.process_data(data, PMDPs.flatrate; folder = OUT_FOLDER, N = N_traces)
    
#     # println("dpw...")
#     # PMDPs.process_data(
#         #     data,
#         #     PMDPs.mcts;
#         #     folder = OUT_FOLDER,
#         #     N = N_traces,
#         #     method_info = "dpw_$(savename(params_dpw))",
#         #     solver = DPWSolver(; params_dpw...),
#         # )
        
#         println("mcts...")
#     PMDPs.process_data(
#         data,
#         PMDPs.mcts;
#         folder = OUT_FOLDER,
#         N = N_traces,
#         method_info = "vanilla_$(savename(params_classical_MCTS))",
#         solver = MCTSSolver(;params_classical_MCTS...),
#         )
# end

# for (i, data) in e_inputs
#     if PMDPs.n_resources(data[:pp])<=8
#         println("vi...")
#         data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder = OUT_FOLDER, N = N_traces)
#     end
# end
        
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