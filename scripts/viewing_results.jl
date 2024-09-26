using DrWatson
using DataFrames
include(srcdir("MDPPricing.jl"))
using .MDPPricing

"""
SELECT EXPERIMENT
"""

# OUT_FOLDER = "tiny_experiments"
# PP_NAME = "tiny_problem_14692157986148999600"

# OUT_FOLDER = "ev_experiments"
# PP_NAME = "single_day_pp_testing_MCTS"

OUT_FOLDER = "ev_experiments"
PP_NAME = "single_day_const_demand_cs_pp"

# nᵣ=48
# OUT_FOLDER = "ev_experiments"
# PP_NAME = "cs_var_demand_$(nᵣ)"

"""
ANALYZE AND PLOT RESULTS
"""

results, raw = MDPPricing.folder_report(datadir(OUT_FOLDER, "results", PP_NAME); raw_result_array=true)

df = results

agg_res = MDPPricing.format_result_table(df)


macro size(expression)
    quote
        value = $expression
        size_B = Base.summarysize(value)
        if size_B > 0
            si_prefix = Dict(0=>(0,""), 1=>(3,"K"), 2=>(6,"M"), 3=>(9,"G"), 4=>(12,"T"))
            order = floor(Int, log(10, size_B))
            exponent, my_prefix = get(si_prefix, floor(Int,order/3), (0, ""))
        else
            exponent, my_prefix = (0,"")
        end
        println("'", $(Meta.quot(expression)), "' size is ", round(size_B/10^exponent; digits=2), " ", my_prefix,"B")
        size_B
    end
end

# @size df

"""
Analyzing traces
"""

# agg_res[!, [1, collect(10:34)...]]
# pp = raw[1][:pp]
# fr = raw[1][:results][!, :]
# vr = raw[4][:results][!, :]

# # f⬆ = .!(fr.r .> vr.r)
# f⬆ = (fr.r .> vr.r)

# "equal: $(sum((fr.r .== vr.r))), flatrate better: $(sum((fr.r .> vr.r))), VI better: $(sum((fr.r .< vr.r)))"

# hcat(fr[f⬆, [1,2]], vr[f⬆, [1,2]], makeunique=true)
# i = 5
# MDPPricing.SimHistoryViewer(pp, fr[f⬆, :][i,:h])
# MDPPricing.SimHistoryViewer(pp, vr[f⬆, :][i,:h])


"""
Plotting results experiments with different PP configurations
"""

using Plots

sort!(df, [:method, :demand_scaling_parameter])
grps = groupby(df, [:method, :objective])
grp = grps[4]

plot(legend=:bottomleft)
for grp in grps
    method_label = grp.method[1][1:min(11, length(grp.method[1]))]
    # method_label = grp.method[1]
    plot!(grp.demand_scaling_parameter, grp.mean_r; label=method_label)
end
plot!()


r  = grps[1][!,[2,6,collect(8:35)...]]

raw_fr = filter(r->r[:method]=="flatrate", raw)
raw_fr = sort(raw_fr; by= r->PMDPs.n_resources(r[:pp]))

let raw=raw_fr, i=12, j=1
    println(i)
    pp = raw[i][:pp]
    h = raw[i][:results][j,:h]
    MDPPricing.SimHistoryViewer(pp, h)
end


"""
Plotting results of testing various MCTS configurations
"""

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
