module PricingMDP

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions
using Combinatorics

import Base.show


#Model definition
export PMDP, PMDPe, PMDPg, State, Action
include("PMDP/PMDP.jl")
include("PMDP/PMDPg.jl")
include("PMDP/PMDPe.jl")


#Tools for defining problem instances
include("problem_definition/graph.jl")
include("problem_definition/product.jl")
include("problem_definition/demand.jl")
include("problem_definition/user_budgets.jl")
include("problem_definition/problems.jl")


# Simulation tools
export run_sim, get_stats, makesim, simulate_trace
include("simulations/simtools.jl")
include("simulations/experiments.jl")
include("simulations/trace_generation.jl")

# Benchmarks
include("baselines/flatrate_baseline.jl")
module LP
    include("baselines/LP.jl")
end

end
