using DrWatson
using DataFrames
include(srcdir("MDPPricing.jl"))
using .MDPPricing

"""
SELECT EXPERIMENT
"""

# OUT_FOLDER = "tiny_experiments"
# PP_NAME = "tiny_problem_14692157986148999600"

OUT_FOLDER = "ev_experiments"
PP_NAME = "single_day_pp_testing_MCTS"

"""
ANALYZE AND PLOT RESULTS
"""

results, raw = MDPPricing.folder_report(datadir(OUT_FOLDER, "results", PP_NAME); raw_result_array=true)

df = results

agg_res = MDPPricing.format_result_table(df)
agg_res[!, [1, collect(10:34)...]]

pp = raw[1][:pp]
fr = raw[1][:results][!, :]
vr = raw[4][:results][!, :]

# f⬆ = .!(fr.r .> vr.r)
f⬆ = (fr.r .> vr.r)

"equal: $(sum((fr.r .== vr.r))), flatrate better: $(sum((fr.r .> vr.r))), VI better: $(sum((fr.r .< vr.r)))"

hcat(fr[f⬆, [1,2]], vr[f⬆, [1,2]], makeunique=true)
i = 5
MDPPricing.SimHistoryViewer(pp, fr[f⬆, :][i,:h])
MDPPricing.SimHistoryViewer(pp, vr[f⬆, :][i,:h])


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