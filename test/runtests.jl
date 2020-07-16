using PricingMDP
using Test

@testset "PricingMDP.jl" begin
    # Write your tests here.
end

@testset "SimplestPricingMDP.jl" begin
    include("test_simplestPricingMDP.jl")
end

@testset "PricingMDPv1.jl" begin
    include("test_pricingMDPv1.jl")
end

@testset "PricingMDPv2.jl" begin
    include("test_pricingMDPv2.jl")
end
