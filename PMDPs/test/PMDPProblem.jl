# using PMDPs
# using Test

using StaticArrays
using Distributions
using PMDPs.CountingProcesses

@testset "PricingProblem.jl" begin
    pp = simple_pp()

    @test isa(pp, PMDPs.PMDPProblem)
    @test PMDPs.selling_period_end(pp) == 8

    @test size(pp) == (3, 2, 5)
end
