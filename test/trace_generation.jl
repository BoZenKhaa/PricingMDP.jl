using Random
using POMDPSimulators

@testset "trace_generation.jl" begin

    mg, me = dead_simple_mdps()
    h = PricingMDP.simulate_trace(mg, MersenneTwister(12))
    @test isa(h, SimHistory)

end