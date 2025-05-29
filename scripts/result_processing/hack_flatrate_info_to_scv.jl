using JLD2, CSV
using PMDPs
using DataFrames


# Flatrate hack - total revenue divided by utilization gives flatrate
function get_flatrate_price_per_timeslot(df)
    flatrate_price_per_timeslot = df[df.r.!=0, :r]./df[df.r.!=0,:u]
    @assert all(map(y->isapprox(y,flatrate_price_per_timeslot[1]), flatrate_price_per_timeslot))
    df = DataFrame(price_per_timeslot=[flatrate_price_per_timeslot[1]])
    return df
end

# filepath = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=240_c=3_expected_res=30_nᵣ=30_res_budget_μ=0.8\results\flatrate\config_flatrate_result.jld2"
# results_data = JLD2.load(filepath)
# df = results_data["jld2_data"][:results]
# flatrate_price_per_timeslot = df[:, :r]./df[:,:u]
# @assert all(map(y->isapprox(y,flatrate_price_per_timeslot[1]), flatrate_price_per_timeslot))
# df = DataFrame(price_per_timeslot=[flatrate_price_per_timeslot[1]])
# save_filepath = replace(filepath, "result.jld2" => "result_price.csv")
# CSV.write(save_filepath, df)


for (root, dirs, files) in walkdir(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources")
    if length(files)>0
        for filepath in files
            if endswith(filepath, "config_flatrate_result.jld2")
                results_data = JLD2.load(joinpath(root,filepath))
                println(joinpath(root,filepath))
                results = results_data["jld2_data"][:results]
                flatrate = get_flatrate_price_per_timeslot(results)
                save_filepath = replace(filepath, "result.jld2" => "result_price.csv")
                CSV.write(joinpath(root,save_filepath), flatrate)
            end
        end
    end
end