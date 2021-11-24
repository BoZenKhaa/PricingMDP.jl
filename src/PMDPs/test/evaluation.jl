using POMDPPolicies
using DataFrames

@testset "evaluation.jl" begin
    mg, me = simple_mdps()
    pp = PMDPs.pp(mg)
    # trace = PMDPs.simulate_trace(mg, MersenneTwister(123))

    # Three non-zero requests with budget 10
    trace = simple_short_trace(pp)

    hrpl = PMDPs.HistoryReplayer(mg, trace)
    hrec = HistoryRecorder(max_steps = PMDPs.selling_period_end(mg), rng = MersenneTwister(4321)) 
    
    # test replay()
    reject =  FunctionPolicy(x->1000.)
    hᵣ = PMDPs.replay(hrpl, reject, MersenneTwister(123))
    @test isa(hᵣ, SimHistory)
    @test [(s = r.s, info=r.info) for r in hᵣ] == trace.hist
    
    # test get_metrics()
    (r,u,nₛ, nᵣ) = PMDPs.get_metrics(hrpl, hᵣ)
    @test (r,u,nₛ, nᵣ) == (0.,0,0,3)

    accept = FunctionPolicy(x->5.)
    hₐ = PMDPs.replay(hrpl, accept, MersenneTwister(123))
    @test PMDPs.get_metrics(hrpl, hₐ) == (r=15., u=3, nₛ=3, nᵣ=3)

    # test eval()
    policies = (vi = PMDPs.get_VI_policy(me), 
                mcts = PMDPs.get_MCTS_planner(mg,
                             params_mcts=Dict(:rng=>Xorshift128Plus(1))),
                hind = PMDPs.LP.get_MILP_hindsight_policy(mg, trace),
                flat =  PMDPs.get_flatrate_policy(mg, [trace, trace]) 
                )

    # Every policy should give optimal allocation for provided trace
    for policy in policies
        @test PMDPs.get_metrics(hrpl, PMDPs.replay(hrpl, policy, MersenneTwister(1))) == (r=30., u=3, nₛ=3, nᵣ=3) 
    end

    metrics = PMDPs.eval_policy(mg, trace, policies, MersenneTwister(1))
    @test isa(metrics, DataFrame)
    @test size(metrics)[1]==length(policies)


    metrics_all = PMDPs.eval_policy(mg, [trace, trace], policies, MersenneTwister(1))
    @test isa(metrics_all, DataFrame)
    @test size(metrics_all)[1]==length(policies)*2
end