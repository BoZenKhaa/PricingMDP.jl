"""
Convert result from evaluating single policy with eval_policy into a single row
"""
function res2row(res)
    row_dfs = []
    
    # process pp_params into df with single row
    row = DataFrame(res[:pp_params])
    push!(row_dfs, row)
    
    # process agg: move evry row from "description" into single dataframe of one row
    agg = select(res[:agg], [:variable, :mean, :median, :min, :max])
    for row in eachrow(agg)
        v = string(row.variable)
        row = DataFrame(row[2:end])
        rename!(s-> s*"_$v", row)
        push!(row_dfs, row)
    end
    
    # compact dfs into single row
    df = hcat(row_dfs...)
    
    # add method
    method = string(first(res[:results]).name)*"_"*res[:method_info]
    insertcols!(df, 1, :method=>method)
    
    # add objective
    if haskey(res[:pp_params], :objective)
        objective = string(res[:pp_params][:objective])
    else
        objective = :revenue
    end
    if !("objective" in names(df))
#         df.objective = objective
        insertcols!(df, 2, :objective=>objective)
    end
    
    # add n_traces
    insertcols!(df, 2, :N=>res[:N])
end

function folder_report(res_folder::String)
    res_files = readdir(res_folder)
    rows = []
    for res_file in res_files
        if res_file[end-4:end]==".bson"
            res = BSON.load(joinpath(res_folder,res_file))
            row = res2row(res)
            push!(rows, row)
        end
    end
    results = vcat(rows...)
end

function format_result_table(results::DataFrame)
    df10 = filter(:N => N->N==10, results)
    gps = groupby(df10, [:objective])

    restable = outerjoin([select(gr, [:method, :N, :objective, :mean_r, :mean_u]) for gr in gps]...; on=[:method, :N], makeunique=true)
    restable = restable[[2,4,5,6,1,3], :]
end