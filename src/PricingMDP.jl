module PricingMDP

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions
using Combinatorics

import Base.show


export PMDP, PMDPe, PMDPg, State, Action, create_continuous_products, create_edges, create_λ
include("PMDP/PDMP.jl")
include("PMDP/PMDPg.jl")
include("PMDP/PMDPe.jl")

include("NRM/NRMProblem.jl")
include("NRM/Product.jl")
include("NRM/Demand.jl")
include("NRM/User.jl")
include("problems.jl")

export run_sim, get_stats, makesim
include("experiments.jl")

# export MILP_hindsight_pricing
# include("milp_hindsight_pricing.jl")

# flatrate baseline
include("flatrate_baseline.jl")

# Subpackages
# export MILP_hindsight_pricing
# export LP.MILP_hindsight_pricing
module LP
# export MILP_hindsight_pricing
include("LP.jl")
end

# include("SimplestPricingMDP.jl")
# include("PricingMDPv1.jl")
end
