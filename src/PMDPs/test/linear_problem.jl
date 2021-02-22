using PMDPs.CountingProcesses
using Distributions

@testset "linear_problem.jl" begin

   pp1 = PMDPs.linear_pp(3)
   PMDPs.PMDPg(pp1)
   
   @test isa(pp1, PMDPs.PMDPProblem)

   pp2 = PMDPs.linear_pp(10; c=5, T=100, expected_res=100., res_budget_μ=5.)
   @test isa(pp2, PMDPs.PMDPProblem) 
end