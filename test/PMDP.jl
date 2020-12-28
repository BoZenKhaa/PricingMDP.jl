using Distributions
using StaticArrays
using POMDPs

@testset "PMDP.jl" begin
    

    # struct ConstUserBudget <: PMDPs.AbstractUserBudget
    #     β::Distribution
    # end

    
    pp = simple_pp()
    mg = PMDPs.PMDPg(pp)
    me = PMDPs.PMDPe(pp)

    for m in [mg,me]
        @test PMDPs.problem(m) == pp
        @test PMDPs.timestep_limit(m) == pp.T
        @test PMDPs.budgets(m) == pp.B
        @test PMDPs.demand(m) == pp.D
        @test POMDPs.actions(m) == mg.pp.A
        @test PMDPs.objective(m) == :revenue
        @test PMDPs.n_res(m) == 2
        
        @test typeof(m) <: PMDPs.PMDP
    end

    @testset "StatePMDPMethods" begin
       s = PMDPs.State(mg, SA[2,3], 5, SA[true, true])
       @test PMDPs.sale_impossible(mg, s) == false
       @test PMDPs.isterminal(mg, s) == false

       # timestep over selling_period_end
       s_afterspe = PMDPs.State(mg, SA[2,3], 7, SA[true, true])
       @test PMDPs.sale_impossible(mg, s_afterspe) == true
       @test PMDPs.isterminal(mg, s_afterspe) == false
       
       # timestep over T
       s_t = PMDPs.State(mg, SA[2,3], 8, SA[true, true])
       @test PMDPs.sale_impossible(mg, s_t) == true
       @test PMDPs.isterminal(mg, s_t) == true    
       
       # some 0 capacity
       s_0c = PMDPs.State(mg, SA[0,3], 3, SA[true, true])
       @test PMDPs.sale_impossible(mg, s_0c) == true
       @test PMDPs.isterminal(mg, s_0c) == false
       
       # 0 capacity
       s_0allc = PMDPs.State(mg, SA[0,0], 3, SA[true, true])
       @test PMDPs.sale_impossible(mg, s_0allc) == true
       @test PMDPs.isterminal(mg, s_0allc) == true
        
       # 0 product
       s_0p = PMDPs.State(mg, SA[2,3], 3, SA[false, false])
       @test PMDPs.sale_impossible(mg, s_0p) == true
       @test PMDPs.isterminal(mg, s_0p) == false
    end
    

end