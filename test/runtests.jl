using PricingMDP
using Test

include("mdp_instances.jl")

@testset "PricingMDP.jl" begin
    include("PMDP.jl")
    include("trace_generation.jl")
end

# @testset "Method consistency" begin
#     include("test_consistency.jl")
# end