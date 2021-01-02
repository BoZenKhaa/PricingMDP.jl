using PMDPs
using Test

# Testing utility code
include("mdp_instances.jl")

@testset "PMDPs.jl" begin
    include("CountingProcesses/runtest.jl")
    include("product.jl")
    include("PMDPProblem.jl")
    include("PMDPg.jl")
    include("PMDPe.jl")
    include("PMDP.jl")
    include("trace_generation.jl")
    # include("policy_tools.jl")
    # include("HistoryReplayer.jl")
    # include("evaluation.jl")
    # include("linear_problem.jl")
end