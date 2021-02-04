using PMDPs
using POMDPs
using Test

run(`clear`)

# Testing utility code
include("_test_tools.jl")

@testset "PMDPs.jl" begin
    include("CountingProcesses/runtest.jl")
    include("product.jl")
    include("PMDPProblem.jl")
    include("PMDPg.jl")
    include("PMDPe.jl")
    include("PMDP.jl")
    include("trace_generation.jl")
    include("policy_tools.jl")
    include("HistoryReplayer.jl")
    include("evaluation.jl")
    include("linear_problem.jl")
    include("graph_problem.jl")
    include("simrunning.jl")
    include("LP.jl")
    include("hindsight_policy.jl")
end