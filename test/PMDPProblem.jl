# using PricingMDP
# using Test

using StaticArrays
using Distributions

function simple_pp()
    P = SA[ PMDPs.Product(SA[true, false], 6), 
            PMDPs.Product(SA[false, true], 8), 
            PMDPs.Product(SA[true, true], 6)]
    D = [1.,1.,1.]
    β = DiscreteNonParametric([10.], [1.])
    B = [β, β, β]
    C₀ = SA[3,3]
    A = [0., 5., 10., 15., 1000.]
    objective = :revenue

    pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
end


@testset "PricingProblem.jl" begin
    pp = simple_pp()

    @test isa(pp, PMDPs.PMDPProblem)
    @test PMDPs.selling_period_end(pp)==8
end