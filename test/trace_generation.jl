using Random
using POMDPSimulators

@testset "trace_generation.jl" begin

    pp = simple_pp()
    mg = PMDPs.PMDPg(pp)
    h = PMDPs.simulate_trace(mg, MersenneTwister(12))
    @test isa(h, SimHistory)

end