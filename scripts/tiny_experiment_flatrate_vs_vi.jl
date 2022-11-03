using PMDPs
using PMDPs.LP
using DrWatson
using Random
using MCTS
using POMDPSimulators
using POMDPPolicies
using DiscreteValueIteration

# using Formatting

import Base.show

using Plots
using Distributions
using ProgressMeter


using POMDPs
using DataFrames
using CSV
using StaticArrays

using Formatting

struct SimHistoryViewer
    pp::PMDPs.PMDPProblem
    trace::SimHistory
end


struct StateViewer
    pp::PMDPs.PMDPProblem
    s::PMDPs.State
end

function Base.show(io::IO,  pw::StateViewer)
    product = PMDPs.product(pw.pp, pw.s)
    product_str = join([v ? "█" : "▒" for v in product])
    print(io, replace(string(pw.s), r"[0-9]*$"=>product_str))
    # print(io, product_str)
end

function Base.show(io::IO, ::MIME"text/plain", sh::SimHistoryViewer)
    for step in sh.trace
        print(io, StateViewer(sh.pp, step.s))
        action = step.a
        budget = step.info.budget
        price = PMDPs.calculate_price(PMDPs.product(sh.pp, step.s), action)

        printfmt(io, " b:{: 6.2f}", budget)
        printfmt(io, " a:{: 6.2f} ({: 6.2f})", action, price)

        if PMDPs.sale_impossible(PMDPs.PMDPg(sh.pp), step.s)
            outcome, color = "🛇", :red
        else
            outcome, color = PMDPs.user_buy(price, budget) ? ("buy", :green) : ("not", :red)
        end

        print(io, " -> ")
        printstyled(io, "$(outcome)"; color=color)
        print(io,"\t")
        try
            printfmt(io, "r:{: 6.2f} ", step.r)
        catch
        end
        print(io, step.sp)
        print(io, "\n")
    end
end

RNG = Xoshiro
include(srcdir("MDPPricing.jl"))

OUT_FOLDER = "tiny_experiments"

# === PP ===
P = SA[
    PMDPs.Product(SA[true, false], 6), # 1
    PMDPs.Product(SA[false, true], 8), # 2
    PMDPs.Product(SA[true, true], 6),
    ]  # 3
C₀ = SA[3, 3]
D = PMDPs.BernoulliScheme(8, [0.3, 0.3, 0.3])
β₁ = DiscreteNonParametric([10.0], [1.0]) # user budget per product
β₂ = DiscreteNonParametric([20.0, 30.0], [0.5, 0.5])
B = [β₁, β₁, β₂]
A = [0.0, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.] # pricing action per resource
objective = PMDPs.REVENUE

# P = SA[
#     PMDPs.Product(SA[true,], 6), # 1
#     ]  # 3
# C₀ = SA[3]
# D = PMDPs.BernoulliScheme(8, [0.9])
# β = DiscreteNonParametric([10.,20.], [.5,.5])
# B = [β,]
# A = [0.0, 5.0, 10.0, 15.0, 20.0]
# objective = PMDPs.REVENUE

pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
pp_params = @dict P C₀ D B A objective
PP_NAME = "tiny_problem_$(hash(pp_params))"


# === Traces ===
vi = true
name = PP_NAME
n_traces = 100

inputs = []
push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=true, folder=OUT_FOLDER, seed=1, save=true))

"""
PREPARE SOLVERS AND RUN EXPERIMENTS
"""

# params_dpw = Dict(
#     pairs((
#         depth=50,
#         exploration_constant=40.0,
#         enable_state_pw=false,
#         keep_tree=true,
#         show_progress=false,
#         rng=RNG(1),
#     )),
# )

# params_classical_MCTS = Dict(
#     pairs((
#         depth=3,
#         exploration_constant=15.0,
#         n_iterations=1000,
#         reuse_tree=true,
#         rng=RNG(1),
#     )),
# )


# MCTSSolver(; params_classical_MCTS...)


# === run experiments === 
N_traces = n_traces
e_inputs = collect(enumerate(inputs[1:end]))

for (i, data) in e_inputs
    println("hindsight...")
    PMDPs.process_data(data, PMDPs.hindsight; folder = OUT_FOLDER, N = N_traces, save_simhistory=true)
end

for (i, data) in e_inputs
    if PMDPs.n_resources(data[:pp])<=6
        println("vi...")
        data[:vi] && PMDPs.process_data(data, PMDPs.vi; folder = OUT_FOLDER, N = N_traces, save_simhistory=true)
    end
end

# Threads.@threads 
for (i, orig_data) in e_inputs
    data = deepcopy(orig_data)
    # println("\t Data - Evaluating $(data[:name]) with $(data[:pp_params]): ")
    println("flatrate...")
    PMDPs.process_data(data, PMDPs.flatrate; folder = OUT_FOLDER, N = N_traces, save_simhistory=true)
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

    # phase 3
    depths = [5,]
    ecs = [15.,]
    n_iter = [2000,]


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
            solver=MCTSSolver(; params_classical_MCTS...), save_simhistory=true
        )
    end
end

"""
ANALYZE AND PLOT RESULTS
"""

results, raw = MDPPricing.folder_report(datadir(OUT_FOLDER, "results", PP_NAME); raw_result_array=true)

df = results

agg_res = MDPPricing.format_result_table(df, N=N_traces)
agg_res[!, [1,collect(10:34)...]]



fr = raw[1][:results][!, :]
vr = raw[4][:results][!, :]

f⬆ = .!(fr.r .> vr.r)


fr[f⬆, :]
i = 2
SimHistoryViewer(pp, fr[f⬆, :][i,:h])
SimHistoryViewer(pp, vr[f⬆, :][i,:h])

vr[f⬆, :][1,:h]



mg = PMDPg(pp)
train_range::UnitRange{Int64}=1:5
rng=RNG(1)
PMDPs.get_flatrate_policy(mg, [PMDPs.generate_request_trace(mg, rng) for i = train_range])

traces = inputs[1][:traces]
traces[99]

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