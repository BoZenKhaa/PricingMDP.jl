using POMDPSimulators


function evaluate_policy(m::PMDP, requests::AbstractSimHistory, policy::Policy)
    s₀ = rand(POMDPs.initialstate(m))    
    c = s₀.c
    reward = 0.
    sales = 0
    actions = Array{Action}
    for r in requests
        s = PricingMDP.State(c, r.s.t, r.s.p)
        a = action(policy, s)
        @show s, a
        if PricingMDP.user_buy(a, r.info)
            reward+=a
            sales+=1
            c = PricingMDP.reduce_capacities(c, r.s.p) 
        end
    end

    return (reard = reward, sales = sales)
end