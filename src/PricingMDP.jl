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
include("PMDP/PDMP.jl")
include("PMDP/PMDPg.jl")
include("PMDP/PMDPe.jl")


#Tools for defining problem instances
export create_continuous_products, create_edges, create_λ
include("problem_definition/Problem.jl")
include("problem_definition/Product.jl")
include("problem_definition/Demand.jl")
include("problem_definition/User.jl")
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
