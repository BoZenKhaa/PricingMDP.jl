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
include("problem_definition/user.jl")
include("problem_definition/problems.jl")


# Simulation tools
export run_sim, get_stats, makesim
include("experiments.jl")


# Benchmarks
include("flatrate_baseline.jl")
module LP
    include("LP.jl")
end

end
