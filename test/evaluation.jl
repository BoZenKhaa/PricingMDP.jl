using POMDPPolicies
using DataFrames

@testset "evaluation.jl" begin
    mg, me = simple_mdps()
    requests = PMDPs.simulate_trace(mg, MersenneTwister(123))
    # Three non-zero requests with budget 10
    
    hrpl = PMDPs.HistoryReplayer(mg, requests)
    hrec = HistoryRecorder(max_steps = mg.T, rng = MersenneTwister(4321)) 
    
    # test replay()
    reject =  FunctionPolicy(x->1000.)
    hᵣ = PMDPs.replay(hrpl, reject, MersenneTwister(123))
    @test isa(hᵣ, SimHistory)
    @test hᵣ==requests
    
    # test get_metrics()
    (r,u,n) = PMDPs.get_metrics(hᵣ)
    @test (r,u,n)==(0.,0,0)

    accept =  FunctionPolicy(x->5.)
    hₐ = PMDPs.replay(hrpl, accept, MersenneTwister(123))
    @test PMDPs.get_metrics(hₐ) == (r=15., u=3, nₛ=3, nᵣ=3)

    # test eval()
    policies = (vi = PMDPs.get_VI_policy(me), 
                mcts = PMDPs.get_MCTS_planner(mg),
                hind = PMDPs.LP.get_MILP_hindsight_policy(mg, requests),
                flat =  PMDPs.get_flatrate_policy(mg, [requests, requests]) 
                )
    metrics = PMDPs.eval(mg, requests, policies, MersenneTwister(1))
    @test isa(metrics, DataFrame)
    @test size(metrics)==(length(policies),7)


    metrics_all = PMDPs.eval(mg, [requests, requests], policies, MersenneTwister(1))
    @test isa(metrics_all, DataFrame)
    @test size(metrics_all)==(length(policies)*2,7)
end