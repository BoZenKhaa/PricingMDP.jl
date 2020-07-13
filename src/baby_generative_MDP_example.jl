# Baby example from https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb

using POMDPs
using Random
using POMDPModelTools

struct BabyPOMDP <: POMDP{Bool, Bool, Bool}
    r_feed::Float64
    r_hungry::Float64
    p_become_hungry::Float64
    p_cry_when_hungry::Float64
    p_cry_when_not_hungry::Float64
    discount::Float64
end

BabyPOMDP() = BabyPOMDP(-5., -10., 0.1, 0.8, 0.1, 0.9);

function POMDPs.gen(m::BabyPOMDP, s, a, rng)
    # transition model
    if a # feed
        sp = false
    elseif s # hungry
        sp = true
    else # not hungry
        sp = rand(rng) < m.p_become_hungry
    end

    # observation model
    if sp # hungry
        o = rand(rng) < m.p_cry_when_hungry
    else # not hungry
        o = rand(rng) < m.p_cry_when_not_hungry
    end

    # reward model
    r = s*m.r_hungry + a*m.r_feed

    # create and return a NamedTuple
    return (sp=sp, o=o, r=r)
end

POMDPs.initialstate_distribution(m::BabyPOMDP) = Deterministic(false)

using POMDPSimulators
using POMDPPolicies

m = BabyPOMDP()

# policy that maps every input to a feed (true) action
policy = FunctionPolicy(o->true)

for (s, a, r) in stepthrough(m, policy, "s,a,r", max_steps=10)
    @show s
    @show a
    @show r
    println()
end
