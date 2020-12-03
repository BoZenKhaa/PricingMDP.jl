using POMDPPolicies
using DataFrames

@testset "evaluation.jl" begin
    mg, me = dead_simple_mdps()
    requests = PricingMDP.simulate_trace(mg, MersenneTwister(123))
    # Three non-zero requests with budget 10
    
    hrpl = PricingMDP.HistoryReplayer(mg, requests)
    hrec = HistoryRecorder(max_steps = mg.T, rng = MersenneTwister(4321)) 
    
    # test replay()
    reject =  FunctionPolicy(x->1000.)
    hᵣ = PricingMDP.replay(hrpl, reject, MersenneTwister(123))
    @test isa(hᵣ, SimHistory)
    @test hᵣ==requests
    
    # test get_metrics()
    (r,u,n) = PricingMDP.get_metrics(hᵣ)
    @test (r,u,n)==(0.,0,0)

    accept =  FunctionPolicy(x->5.)
    hₐ = PricingMDP.replay(hrpl, accept, MersenneTwister(123))
    @test PricingMDP.get_metrics(hₐ) == (r=15., u=3, nₛ=3, nᵣ=3)

    # test eval()
    policies = (vi = PricingMDP.get_VI_policy(me), 
                mcts = PricingMDP.get_MCTS_planner(mg),
                hind = PricingMDP.LP.get_MILP_hindsight_policy(mg, requests),
                flat =  PricingMDP.get_flatrate_policy(mg, [requests, requests]) 
                )
    metrics = PricingMDP.eval(mg, requests, policies, MersenneTwister(1))
    @test isa(metrics, DataFrame)
    @test size(metrics)==(length(policies),7)


    metrics_all = PricingMDP.eval(mg, [requests, requests], policies, MersenneTwister(1))
    @test isa(metrics_all, DataFrame)
    @test size(metrics_all)==(length(policies)*2,7)
end