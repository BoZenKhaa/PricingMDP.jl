"""
Generate a history of requests from given MDP. 

This method is used to genereate sequences of requests for the experiments.
"""
function simulate_trace(m::PMDP,rng::AbstractRNG)
    hr = HistoryRecorder(max_steps=selling_period_end(m), rng = rng)
    reject = FunctionPolicy(s->1000.)
    history = simulate(hr, m, reject)
end

function load_traces(fname)
    data = load(fname)
    traces = data[:traces]
    @assert all(y->typeof(y)==typeof(traces[1]), traces) "traces contain elements of different types!"
    data[:traces] = [traces...] # this repackages the loaded array of typr Array{Any,1} into Array{SimHistory, 1}
    return data
end