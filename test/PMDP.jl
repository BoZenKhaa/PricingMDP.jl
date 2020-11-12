using Distributions

@testset "PMDP.jl" begin
    

    struct ConstUserBudget <: PricingMDP.AbstractUserBudget
        β::Distribution
    end

    β = DiscreteNonParametric([10.], [1.])

    E = [PricingMDP.Edge(1, 2, 6), # id, c, spe 
        PricingMDP.Edge(2, 3, 8)]
    P = [Product{2}[false, false], Product{2}[true, false],Product{2}[false, true],Product{2}[true, true]]
    λ = [3.,3.,3.,3.]
    B = [β, β, β, β]
    A = [0., 5., 10., 15., 1000.]
    objective = :revenue

    @test typeof(PMDPg(E, P, λ, B, A, objective)) <:PMDP
    @test typeof(PMDPe(E, P, λ, B, A, objective)) <:PMDP


end