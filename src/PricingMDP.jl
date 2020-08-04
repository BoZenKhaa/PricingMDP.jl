module PricingMDP

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions
using Combinatorics

import Base.show

export PMDP, State, Action, create_continuous_products, create_edges, create_λ
include("PricingMDPv2.jl")
include("NRM/NRMProblem.jl")
include("NRM/Product.jl")
include("NRM/Demand.jl")
include("NRM/User.jl")

# Subpackages
include("SimplestPricingMDP.jl")
include("PricingMDPv1.jl")
end
