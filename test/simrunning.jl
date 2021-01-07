using DataFrames
using DiscreteValueIteration

@testset "simrunning.jl" begin
    pp = simple_pp()
    trace = simple_trace(pp)
    traces = [trace, trace]

    
    pp_params = Dict(:test=>1)
    name = "test_problem"
    data = @dict(traces, pp, pp_params, name)
    
    @test isa(PMDPs.flatrate(pp, traces, MersenneTwister(1)), DataFrame)
    
    PMDPs.process_data(data, PMDPs.flatrate)
    @test isfile(datadir("results", "test_problem", "flatrate_N=2_test=1.bson"))

    PMDPs.process_data(data, PMDPs.hindsight)
    @test isfile(datadir("results", "test_problem", "hindsight_N=2_test=1.bson"))

    # PMDPs.vi(pp, pp_params, traces, rnd)
    PMDPs.process_data(data, PMDPs.vi)
    @test isfile(datadir("results", "test_problem", "vi_N=2_test=1.bson"))
    @test isfile(datadir("vi_policies", "test_problem", "vi_test=1_.bson" ))
    PMDPs.process_data(data, PMDPs.vi)

    PMDPs.process_data(data, PMDPs.mcts)
    @test isfile(datadir("results", "test_problem", "mcts_N=2_test=1.bson"))

    rm(datadir("results", "test_problem"), recursive=true)
    rm(datadir("vi_policies", "test_problem"), recursive=true)
end