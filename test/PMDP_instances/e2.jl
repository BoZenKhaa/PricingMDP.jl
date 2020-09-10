using PricingMDP
using StaticArrays
using POMDPs
using POMDPModelTools

n_edges = 2
c_init = 2
selling_horizon_end = [10,10]
demand = Float64[2,2]
actions = Action[0,15,30,45,1000]

# edges = create_edges(n_edges, c_init, selling_horizon_end)
# products = create_continuous_products(edges)
# λ = create_λ(demand, products)

# mdp = PMDPe(edges, products, λ, actions);
PricingMDP.create_PMDP(PMDPe)

# testing = false
# if testing
#     @time sts = states(mdp);
#     @time acts = actions(mdp);

#     s = sts[9000]

#     @time transition(mdp, s, acts[5]);

#     @time stateindex(mdp, s);

#     @time actionindex(mdp, acts[5])
#     using Traceur
#     # @trace(actionindex(mdp, acts[5]), modules=[PricingMDP])
# end