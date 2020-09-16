module PricingMDP

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions
using Combinatorics

import Base.show

export PMDP, PMDPe, PMDPg, State, Action, create_continuous_products, create_edges, create_λ
include("PricingMDPv2.jl")
include("NRM/NRMProblem.jl")
include("NRM/Product.jl")
include("NRM/Demand.jl")
include("NRM/User.jl")
include("problems.jl")
include("experiments.jl")

# export MILP_hindsight_pricing
# include("milp_hindsight_pricing.jl")

# Subpackages
# export MILP_hindsight_pricing
include("LP.jl")
include("SimplestPricingMDP.jl")
include("PricingMDPv1.jl")
end
