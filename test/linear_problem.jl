@testset "linear_problem.jl" begin

    # Prepare an instance using utility methods and test that it gets solved
    mg = PricingMDP.simple_linear_PMDP(PMDPg)
    @test isa(mg, PMDPg)

end