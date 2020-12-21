using PMDPs
using Test

# Testing utility code
include("mdp_instances.jl")

@testset "PricingMDP.jl" begin
    include("PMDPProblem.jl")
    include("PMDPg.jl")
    # include("PMDP.jl")
    # include("trace_generation.jl")
    # include("policy_tools.jl")
    # include("HistoryReplayer.jl")
    # include("evaluation.jl")
    # include("linear_problem.jl")
end