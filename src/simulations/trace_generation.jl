"""
Generate a history of requests from given MDP. 

This method is used to genereate sequences of requests for the experiments.
"""
function simulate_trace(m::PMDP,rng::AbstractRNG)
    hr = HistoryRecorder(max_steps=selling_period_end(m), rng = rng)
    reject = FunctionPolicy(s->1000.)
    history = simulate(hr, m, reject)
end

"""
Apply BSON specific fixes to loaded trace data
"""
function load_traces(fname)
    data = load(fname)

    # fix type of traces
    traces = data[:traces]
    @assert all(y->typeof(y)==typeof(traces[1]), traces) "traces contain elements of different types!"
    data[:traces] = [traces...] # this repackages the loaded array of typr Array{Any,1} into Array{SimHistory, 1}
    
    # fix type of pp_params
    pp_params = data[:pp_params]
    data[:pp_params] = Dict(pp_params...)

    return Dict(data)
end