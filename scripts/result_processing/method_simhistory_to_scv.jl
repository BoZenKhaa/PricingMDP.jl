using JLD2, CSV
using PMDPs
using DataFrames

product2string(p::PMDPs.Product) = reduce(*, map(v-> v ? "1" : "0", p.res))


filepath_mcts = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources_higher_demand\single_day_cs_pp_T=48_c=3_expected_res=6_nᵣ=2_res_budget_μ=12.0\results\mcts\config_mcts_depth=3_exploration_constant=3.0_n_iterations=10000_reuse_tree=false_result.jld2"
filepath_vi = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources_higher_demand\single_day_cs_pp_T=48_c=3_expected_res=6_nᵣ=2_res_budget_μ=12.0\results\vi\config_vi_belres=1e-6_max_iterations=100_verbose=true_result.jld2"
filepath_flatrate = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources_higher_demand\single_day_cs_pp_T=48_c=3_expected_res=6_nᵣ=2_res_budget_μ=12.0\results\flatrate\config_flatrate_result.jld2"
filepath_oracle = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources_higher_demand\single_day_cs_pp_T=48_c=3_expected_res=6_nᵣ=2_res_budget_μ=12.0\results\hindsight\config_hindsight_result.jld2"


function JLD2result_histories2CSV(filepath::String)
    data = JLD2.load(filepath)

    # h = data["jld2_data"][:results].h[1]

    pp = data["jld2_data"][:pp]
    products = PMDPs.products(pp)
    empty_product_id = PMDPs.empty_product_id(pp)

    compacted_histories = DataFrame(trace_id=Int64[],timestep=Int64[], budget=Float64[], action=Float64[], sold = Bool[], product=String[])

    for (i, history) in enumerate(data["jld2_data"][:results].h)
        for step in history
            if step.s.iₚ != empty_product_id
                # println(products[step.s.iₚ])
                # println(step.t)
                # println(step.info.budget)
                # println(step.action_info)
                # println(step.a)
                # println(step.s.c != step.sp.c)
                push!(compacted_histories, (
                    trace_id=i, 
                    timestep=step.t, 
                    budget=step.info.budget, 
                    action=step.a, 
                    sold=step.s.c != step.sp.c, 
                    product=product2string(products[step.s.iₚ]))
                    )
            end
        end
    end
        
    save_filepath = replace(filepath, ".jld2" => ".csv")
    CSV.write(save_filepath, compacted_histories)
    return compacted_histories
end

# h_f, ch_f = JLD2result_histories2CSV(filepath_flatrate)
# h_m, ch_m = JLD2result_histories2CSV(filepath_mcts)
# h_o, ch_o = JLD2result_histories2CSV(filepath_oracle)
# h_v, ch_v = JLD2result_histories2CSV(filepath_vi)

# ch_f[ch_f.trace_id .== 1, :]
# ch_m[ch_m.trace_id .== 1, :]
# ch_o[ch_o.trace_id .== 1, :]
# ch_v[ch_v.trace_id .== 1, :]

# ch_f

# h_o
# h_m
# h_v


for (root, dirs, files) in walkdir(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_demand")
    if length(files)>0
        for file in files
            if splitext(file)[2] == ".jld2"  && splitext(file)[1][end-5:end]=="result"
                # println(splitext(file)[1][end-5:end])
                println(joinpath(root, file))
                JLD2result_histories2CSV(joinpath(root, file))
            end
        end
    end
end