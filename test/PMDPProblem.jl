# using PricingMDP
# using Test

using StaticArrays
using Distributions

@testset "PricingProblem.jl" begin
    P = SA[ PricingMDP.Product(SA[true, false], 6), 
            PricingMDP.Product(SA[false, true], 8), 
            PricingMDP.Product(SA[true, true], 6)]
    D = [1.,1.,1.]
    β = DiscreteNonParametric([10.], [1.])
    B = [β, β, β]
    C₀ = SA[3,3]
    A = [0., 5., 10., 15., 1000.]
    objective = :revenue

    pp = PricingMDP.PMDPProblem(P, C₀, D, B, A, objective)

    @test isa(pp, PricingMDP.PMDPProblem)
    @test PricingMDP.selling_period_end(pp)==8
end