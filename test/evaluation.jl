using POMDPPolicies

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
    @test PricingMDP.get_metrics(hₐ) == (r=15., u=3, n=3)

    # test eval()
    policies = (vi = PricingMDP.get_VI_policy(me), 
                mcts = PricingMDP.get_MCTS_planner(mg),
                hind = PricingMDP.LP.get_MILP_hindsight_policy(mg, requests),
                flat =  PricingMDP.get_flatrate_policy(mg, [requests, requests]) 
                )
    PricingMDP.eval(mg, requests, policies, MersenneTwister(1))

    # test evaluation of VI
    # policy = PricingMDP.get_VI_policy(me)
    
    # hᵥ = simulate(hrec, hrpl, policy)
    # @test length(hᵥ) == length(requests)
    # @test sum(collect(hᵥ[:r])) > 0.

    # # test MCTS with historyReplayer
    # planner = PricingMDP.get_MCTS_planner(mg; params_mcts = Dict(:rng=>MersenneTwister(1)))
    # hₘ = simulate(hrec, hrpl, planner)
    # @test length(hₘ) == length(requests)
    # @test sum(collect(hₘ[:r])) > 0.

    # # test hindsight with historyReplayer
    # hindsight = PricingMDP.LP.get_MILP_hindsight_policy(mg, requests)
    # hₕ = simulate(hrec, hrpl, hindsight)
    # @test length(hₕ) == length(requests)
    # @test sum(collect(hₕ[:r])) > 0.   

    # # test flatrate with historyReplayer
    # # R, U = PricingMDP.optimize_flatrate_policy(mg, [requests, requests])
    # flatrate = PricingMDP.get_flatrate_policy(mg, [requests, requests])
    # hᵣ = simulate(hrec, hrpl, flatrate)
    # @test length(hᵣ) == length(requests)
    # @test sum(collect(hᵣ[:r])) > 0.   

end