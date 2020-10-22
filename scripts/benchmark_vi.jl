using PricingMDP
using BenchmarkTools
using Profile
using StatProfilerHTML #statprofilehtml() after profiling or @profilehtml macro
# using POMDPs
# using DiscreteValueIteration
# using StaticArrays
# using Distributions

"""
The value iteration is slow, probably because the state space takes too long to create. 
In this file, I would like to figure out whether that's true and improve it.

"""


"""
Original:
  memory estimate:  391.39 KiB
  allocs estimate:  6741
  --------------
  minimum time:     445.701 μs (0.00% GC)
  median time:      484.200 μs (0.00% GC)
  mean time:        620.381 μs (9.73% GC)
  maximum time:     29.076 ms (93.49% GC)
  --------------
  samples:          8029
  evals/sample:     1

Using Cartesian/Linear index:
"""
mdp_params = Dict(pairs( (n_edges = 1, c_init = 1, demand = Float64[1], selling_horizon_end = [10], actions = [15., 25.], objective=:revenue)))
mdp_vi = PricingMDP.create_PMDP(PMDPe; mdp_params...);
PricingMDP.get_VI_policy(mdp_vi)
@benchmark PricingMDP.get_VI_policy($mdp_vi)
@profilehtml PricingMDP.get_VI_policy(mdp_vi);



mdp_params = Dict(pairs( (n_edges = 2, c_init = 2, demand = Float64[1,1], selling_horizon_end = [45,50], actions = 15:5:90, objective=:revenue)))
mdp_vi = PricingMDP.create_PMDP(PMDPe; mdp_params...);
@benchmark PricingMDP.get_VI_policy($mdp_vi)
@profilehtml PricingMDP.get_VI_policy(mdp_vi);
statprofilehtml() # Profile.print()

"""
Original:
  memory estimate:  1.94 GiB
  allocs estimate:  22690518
  --------------
  minimum time:     21.804 s (0.87% GC)
  median time:      21.804 s (0.87% GC)
  mean time:        21.804 s (0.87% GC)
  maximum time:     21.804 s (0.87% GC)
  --------------
  samples:          1
  evals/sample:     1

Using Cartesian/Linear index:
  memory estimate:  2.90 GiB
  allocs estimate:  42680945
  --------------
  minimum time:     5.199 s (6.67% GC)
  median time:      5.199 s (6.67% GC)
  mean time:        5.199 s (6.67% GC)
  maximum time:     5.199 s (6.67% GC)
  --------------
  samples:          1
  evals/sample:     1
  """
mdp_params = Dict(pairs( (n_edges = 3, c_init = 2, demand = Float64[1,1,1], selling_horizon_end = [40,45,50], actions = 15:5:90, objective=:revenue)))
mdp_vi = PricingMDP.create_PMDP(PMDPe; mdp_params...);
@benchmark PricingMDP.get_VI_policy($mdp_vi)
@profile PricingMDP.get_VI_policy(mdp_vi);
statprofilehtml() # Profile.print()


mdp_params = Dict(pairs( (n_edges = 5, c_init = 2, demand = Float64[1,1,1,1,1], selling_horizon_end = [40,45,50,60,70], actions = 15:5:90, objective=:revenue)))
mdp_vi = PricingMDP.create_PMDP(PMDPe; mdp_params...);
# @benchmark PricingMDP.get_VI_policy($mdp_vi)
@profilehtml PricingMDP.get_VI_policy(mdp_vi);
# statprofilehtml() # Profile.print()

# mdp_params = Dict(pairs( (n_edges = 5, c_init = 2, demand = Float64[1,1,1,1,1], selling_horizon_end = [40,45,50,60,70], actions = 15:5:90, objective=:revenue)))
# mdp_vi = PricingMDP.create_PMDP(PMDPe; mdp_params...)
# policy = PricingMDP.get_VI_policy(mdp_vi);