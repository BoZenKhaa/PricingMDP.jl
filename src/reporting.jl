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
    
    # add method and its order
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

    # add pp_params_string (without :objective)
    insertcols!(df,2, :pp_params_str=> string(delete!(Dict(res[:pp_params]), :objective)))

end

function folder_report(res_folder::String; raw_result_array=false)
    res_files = readdir(res_folder)
    rows = []
    raw = []
    for res_file in res_files
        if res_file[end-4:end]==".bson"
            res = BSON.load(joinpath(res_folder,res_file))
            row = res2row(res)
            push!(rows, row)
            raw_result_array && push!(raw, res)
        end
    end
    results = vcat(rows...)
    (;results=results, raw=raw)
end

function format_result_table(results::DataFrame;N=10)

    columns = [:method, :pp_params_str, :objective, :mean_r, :mean_u, :mean_bytes, :mean_time]

    df10 = filter(:N => N->N==N, results)
    gps = groupby(df10, [:objective])

    restable = outerjoin(
        [select(gr, columns) for gr in gps]...; 
        on=[:method, :pp_params_str], makeunique=true, renamecols = "_obj_r" => "_obj_u")

    # restable = restable[:, [1,2,8,9,10,11,12,18,19,20,21,22]]
    sort!(restable, [:pp_params_str, order(:method, rev=true)])
end