using Distributions
using StaticArrays
using POMDPs

@testset "PMDP.jl" begin
    

    # struct ConstUserBudget <: PricingMDP.AbstractUserBudget
    #     β::Distribution
    # end

    mg, me = dead_simple_mdps()


    for m in [mg, me]
        @test POMDPs.actions(m) == mg.actions
        @test typeof(m) <:PMDP
    end

    @testset "State" begin
       s = PricingMDP.State(SA[2,3], 5, SA[true, true])
       @test PricingMDP.sale_impossible(mg, s) == false
       @test PricingMDP.isterminal(mg, s) == false

       # timestep over selling_period_end
       s_afterspe = PricingMDP.State(SA[2,3], 7, SA[true, true])
       @test PricingMDP.sale_impossible(mg, s_afterspe) == true
       @test PricingMDP.isterminal(mg, s_afterspe) == false
       
       # timestep over T
       s_t = PricingMDP.State(SA[2,3], 8, SA[true, true])
       @test PricingMDP.sale_impossible(mg, s_t) == true
       @test PricingMDP.isterminal(mg, s_t) == true    
       
       # some 0 capacity
       s_0c = PricingMDP.State(SA[0,3], 3, SA[true, true])
       @test PricingMDP.sale_impossible(mg, s_0c) == true
       @test PricingMDP.isterminal(mg, s_0c) == false
       
       # 0 capacity
       s_0allc = PricingMDP.State(SA[0,0], 3, SA[true, true])
       @test PricingMDP.sale_impossible(mg, s_0allc) == true
       @test PricingMDP.isterminal(mg, s_0allc) == true
        
       # 0 product
       s_0p = PricingMDP.State(SA[2,3], 3, SA[false, false])
       @test PricingMDP.sale_impossible(mg, s_0p) == true
       @test PricingMDP.isterminal(mg, s_0p) == false
    end
    

end