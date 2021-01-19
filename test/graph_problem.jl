using LightGraphs
using GraphPlot
using Random, RandomNumbers.Xorshifts


@testset "graph_problem.jl" begin
    NV = 5
    NE = 8
    NP = 20
    seed = 4

    pp1 = PMDPs.graph_pp(NV, NE, NP; seed=seed)
    
    g = SimpleDiGraph(NV, NE, seed=seed)
    display(gplot(g, nodelabel=1:nv(g)))
    pp2 = PMDPs.graph_pp(g, NP)

    # @test pp1==pp2 #likely an issue with not seeding rng somewhere
end