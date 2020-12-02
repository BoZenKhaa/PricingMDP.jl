using PricingMDP
using Test

# Testing utility code
include("mdp_instances.jl")

@testset "PricingMDP.jl" begin
    include("PMDP.jl")
    include("trace_generation.jl")
    include("policy_tools.jl")
    include("HistoryReplayer.jl")
    include("evaluation.jl")
    include("linear_problem.jl")
end