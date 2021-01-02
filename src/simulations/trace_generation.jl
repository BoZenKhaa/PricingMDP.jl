using Random
using POMDPPolicies
using POMDPSimulators

"""
Generate a history of requests from given MDP. 

This method is used to genereate sequences of requests for the experiments.
"""
function simulate_trace(m::PMDP,rng::AbstractRNG)
    hr = HistoryRecorder(max_steps=selling_period_end(m), rng = rng)
    reject = FunctionPolicy(s->1000.)
    history = simulate(hr, m, reject)
end