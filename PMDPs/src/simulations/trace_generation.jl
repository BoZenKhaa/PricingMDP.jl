"""
Generate a history of requests from given MDP. 

This method is used to genereate sequences of requests for the experiments.
"""
function simulate_trace(m::PMDP, rng)
    hr = HistoryRecorder(max_steps = selling_period_end(m), rng = rng)
    reject = FunctionPolicy(s -> 1000.0)
    history = simulate(hr, m, reject)
end

"""
Getting around the fact that jld2 can save only dicts with strings for keys in the top level structure

Load and resave these as symbols.

The two additional fields come from DrWatson.@tagsave
"""
function load_tagsaved_jld2_traces(fname)
    jld2_data = load(fname)
    data = jld2_data["jld2_data"]
    data[:gitcommit] = jld2_data["gitcommit"]
    data[:script] = jld2_data["script"]
    return data
end


"""
Apply BSON specific fixes to loaded trace data
"""
function load_tagsaved_bson_traces(fname)
    data = load(fname)

    # fix type of traces
    traces = data[:traces]
    @assert all(y -> typeof(y) == typeof(traces[1]), traces) "traces contain elements of different types!"
    data[:traces] = [traces...] # this repackages the loaded array of typr Array{Any,1} into Array{SimHistory, 1}

    # fix type of pp_params
    pp_params = data[:pp_params]
    data[:pp_params] = Dict(pp_params...)

    return Dict(data)
end
