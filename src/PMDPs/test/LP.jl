using PMDPs, PMDPs.LP
using JuMP, GLPK

@testset "LP" begin
    
    pp = simple_pp()
    traces = [simple_short_trace(pp), empty_trace(pp),] 
    _, exhaust = simple_exhaust_capacity_trace(pp)
    diff = simple_trace_different_utility_revenue_optim_allocs(pp)
    mg = PMDPs.PMDPg(pp)


    # revenue
    r, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, traces[1])
    @test @ntuple(r,u,alloc,action_seq) == (r=30.,u=3, alloc=[1.,1.,1.],action_seq=[10.,10.,10.])

    r, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, traces[2])
    @test @ntuple(r,u,alloc,action_seq) == (r=0.,u=0, alloc=[],action_seq=[])
    
    r, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, exhaust)
    @test @ntuple(r,u,alloc,action_seq) == (r=55.,u=6, alloc=[1., 1., 1., 0., 0.,1., 1.],
                action_seq = [10.0, 10.0, 10.0, PMDPs.REJECT_ACTION, PMDPs.REJECT_ACTION, 15.0, 10.0]) 

    r, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, diff)
    @test @ntuple(r,u,alloc,action_seq) == (r=30.,u=4, alloc=[1., 1., 1., 0., 0.],
                action_seq = [10.0, 10., 10., PMDPs.REJECT_ACTION,  PMDPs.REJECT_ACTION]) 
    
    # utilization
    obj_val, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, traces[1]; objective=:utilization)
    @test @ntuple(obj_val,u,alloc,action_seq) == (obj_val=3.,u=3, alloc=[1.,1.,1.],action_seq=[10.,10.,10.])

    obj_val, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, traces[2]; objective=:utilization)
    @test @ntuple(obj_val,u,alloc,action_seq) == (obj_val=0.,u=0, alloc=[],action_seq=[])
    
    obj_val, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, exhaust; objective=:utilization)
    @test @ntuple(obj_val,u,alloc,action_seq) == (obj_val=6.,u=6, alloc=[1., 1., 1., 0., 0.,1., 1.],
                action_seq = [10.0, 10.0, 10.0, PMDPs.REJECT_ACTION, PMDPs.REJECT_ACTION, 15.0, 10.0]) 
    
    obj_val, u, alloc, action_seq, requests = LP.MILP_hindsight_pricing(mg, diff; objective=:utilization)
    @test @ntuple(obj_val,u,alloc,action_seq) == (obj_val=5., u=5, alloc=[1., 1., 0., 1., 0.,],
                action_seq = [10., 10., PMDPs.REJECT_ACTION, 10., PMDPs.REJECT_ACTION]) 
end