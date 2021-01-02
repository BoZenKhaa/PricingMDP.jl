# using PricingMDP
# using Test

using StaticArrays
using Distributions
using PMDPs.CountingProcesses

function simple_pp()
    P = SA[ PMDPs.Product(SA[true, false], 6), 
            PMDPs.Product(SA[false, true], 8), 
            PMDPs.Product(SA[true, true], 6)]
    D = BernoulliScheme(8, [0.1, 0.1, 0.1]) 
    β = DiscreteNonParametric([10.], [1.])
    B = [β, β, β]
    C₀ = SA[3,3]
    A = [0., 5., 10., 15.]
    objective = :revenue

    pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
end


@testset "PricingProblem.jl" begin
    pp = simple_pp()

    @test isa(pp, PMDPs.PMDPProblem)
    @test PMDPs.selling_period_end(pp)==8

    @test size(pp) == (3,2,5)
end