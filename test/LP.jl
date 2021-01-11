using PMDPs.LP
using JuMP, GLPK

@testset "LP" begin
    
    pp = simple_pp()
    traces = [simple_trace(pp), empty_trace(pp)]
    mg = PMDPs.PMDPg(pp)

    r, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, traces[1])
    @test @ntuple(r,u,alloc,action_seq) == (r=30.,u=3, alloc=[1.,1.,1.],action_seq=[10.,10.,10.])

    r, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, traces[2])
    @test @ntuple(r,u,alloc,action_seq) == (r=0.,u=0, alloc=[],action_seq=[])
end