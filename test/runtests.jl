using PricingMDP
using Test

include("mdp_instances.jl")

@testset "PricingMDP.jl" begin
    include("PMDP.jl")
    include("trace_generation.jl")
    include("policy_tools.jl")
    include("HistoryReplayer.jl")
    include("evaluation.jl")
end

# @testset "Method consistency" begin
#     include("test_consistency.jl")
# end