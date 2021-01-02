using Random
using POMDPSimulators
using PMDPs.LP

function simple_trace(pp::PMDPs.PMDPProblem)
    SimHistory([
        (s = PMDPs.State(pp.c₀, 1, 1), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 3, 2), info = (b=10.,)),
        (s = PMDPs.State(pp.c₀, 5, 2), info = (b=10.,))
    ], 1., nothing, nothing)
end

@testset "HistoryReplayer.jl" begin
    mg, me = simple_mdps()
    pp = PMDPs.problem(mg)

    # History replayer takes either full SimulationHistory structure
    simhistory = PMDPs.simulate_trace(mg, MersenneTwister(1))
    # Or more limited structure containing Abstract Arrays of NamedTuples that contain state and info fields.
    trace = simple_trace(pp)

    @test isa(PMDPs.HistoryReplayer(mg, simhistory), PMDPs.PMDP)
    @test isa(PMDPs.HistoryReplayer(mg, trace), PMDPs.PMDP)

    hrpl = PMDPs.HistoryReplayer(mg, trace)

    # Test some basic properties
    @test POMDPs.actions(hrpl) == POMDPs.actions(mg)
    
    # Test gen method
    s = trace[1].s
    (sp, r, info) = POMDPs.gen(hrpl, s, 1000., MersenneTwister(99))
    @test sp == trace[2].s
    @test r == 0.
    @test info == trace[1].info
    
    # s = PMDPs.State(SA[2,3], 5, SA[true, true])
    
    # test that the new trace from replayer matches the input trace
    hrpl_sim = PMDPs.HistoryReplayer(mg, simhistory)
    t = PMDPs.simulate_trace(hrpl_sim, MersenneTwister(321))
    @test t == simhistory    

    # TODO: The following should likely be tested in tests of the specific policies

    hrec = HistoryRecorder(max_steps = PMDPs.selling_period_end(mg), rng = MersenneTwister(4321)) 
    
    # test VI with HistoryReplayer
    policy = PMDPs.get_VI_policy(me)
    hᵥ = simulate(hrec, hrpl, policy)
    @test length(hᵥ) == length(trace)
    @test sum(collect(hᵥ[:r])) > 0.

    # test MCTS with historyReplayer
    planner = PMDPs.get_MCTS_planner(mg; params_mcts = Dict(:rng=>MersenneTwister(1)))
    hₘ = simulate(hrec, hrpl, planner)
    @test length(hₘ) == length(trace)
    @test sum(collect(hₘ[:r])) > 0.

    # test hindsight with historyReplayer
    hindsight = PMDPs.LP.get_MILP_hindsight_policy(mg, trace)
    hₕ = simulate(hrec, hrpl, hindsight)
    @test length(hₕ) == length(trace)
    @test sum(collect(hₕ[:r])) > 0.   

    # test flatrate with historyReplayer
    # R, U = PMDPs.optimize_flatrate_policy(mg, [trace, trace])
    flatrate = PMDPs.get_flatrate_policy(mg, [trace, trace])
    hᵣ = simulate(hrec, hrpl, flatrate)
    @test length(hᵣ) == length(trace)
    @test sum(collect(hᵣ[:r])) > 0.   

end