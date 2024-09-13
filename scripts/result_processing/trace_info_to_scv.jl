using JLD2, CSV
using PMDPs
using DataFrames

product2string(p::PMDPs.Product) = reduce(*, map(v-> v ? "1" : "0", p.res))

function trace2dataframe(trace, pp)
    data = DataFrame(time=Int64[], budget=Float64[], product=String[])
    products = PMDPs.products(pp)
    for s in trace
        if s.s.iₚ!=PMDPs.empty_product_id(pp)
            println(products[s.s.iₚ])
            println(s.t)
            println(s.info.budget)
            push!(data, (time=s.t, budget=s.info.budget, product=product2string(products[s.s.iₚ])))
        end
    end
    return data
end

function JLD2traces2CSV(filepath::String)
    traces_data = JLD2.load(filepath)
    traces = traces_data["jld2_data"][:traces]
    pp = traces_data["jld2_data"][:pp]
    products = PMDPs.products(pp)
    data = DataFrame(trace_id=Int64[],timestep=Int64[], budget=Float64[], product=String[])
    for (i, trace) in enumerate(traces)
        for s in trace
            if s.s.iₚ!=PMDPs.empty_product_id(pp)
                push!(data, (trace_id=i, timestep=s.t, budget=s.info.budget, product=product2string(products[s.s.iₚ])))
            end
        end
    end
    save_filepath = replace(filepath, ".jld2" => ".csv")
    CSV.write(save_filepath, data)
end

# filepath = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=768_c=3_expected_res=96_nᵣ=96_res_budget_μ=0.25\traces\traces_N=100_seed=888.jld2"
# traces_data = JLD2.load(filepath)
# # JLD2traces2CSV(filepath)
# traces = traces_data["jld2_data"][:traces]
# pp = traces_data["jld2_data"][:pp]

# products = PMDPs.products(pp)

# t = traces[1]
# data = DataFrame(time=Int64[], budget=Float64[], product=String[])
# for s in t
#     if s.s.iₚ!=PMDPs.empty_product_id(pp)
#         println(products[s.s.iₚ])
#         println(s.t)
#         println(s.info.budget)
#         push!(data, (time=s.t, budget=s.info.budget, product=product2string(products[s.s.iₚ])))
#     end
# end
# CSV.write("traces.csv", data)


for (root, dirs, files) in walkdir(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_demand/")
    if length(files)>0
        for file in files
            if splitext(file)[2] == ".jld2"  && file[1:6]=="traces"
                println(joinpath(root, file))
                JLD2traces2CSV(joinpath(root, file))
            end
        end
    end
end