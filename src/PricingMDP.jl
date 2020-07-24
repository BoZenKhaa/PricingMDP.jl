module PricingMDP

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions
using Combinatorics

import Base.show

export PMDPv2, State, create_continuous_products, create_edges, create_λ
include("PricingMDPv2.jl")

# Subpackages
include("SimplestPricingMDP.jl")
include("PricingMDPv1.jl")
end
