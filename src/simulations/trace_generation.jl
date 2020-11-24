using Random
using POMDPPolicies
using POMDPSimulators

function simulate_trace(m::PMDP,rng::AbstractRNG)
    hr = HistoryRecorder(max_steps=m.T, rng = rng)
    reject = FunctionPolicy(s->1000.)
    history = simulate(hr, m, reject)
end