using PMDPs
using PMDPs.LP
using BSON
using DataFrames
using Random, RandomNumbers.Xorshifts

@testset "hindsight_policy.jl" begin
    pp_params = Dict{Symbol,Any}(
        :T => 1000,
        :c => 40,
        :res_budget_μ => 5.0,
        :nᵣ => 10,
        :expected_res => 1200.0,
    )
    pp = PMDPs.linear_pp(; pp_params...)

    mg = PMDPs.PMDPg(pp)
    rnd = Xorshift128Plus(1)
    traces = [PMDPs.simulate_trace(mg, rnd) for i = 1:3]

    # get results by applying MILP based hindsight policy
    results = PMDPs.hindsight(pp, traces, MersenneTwister(1))

    # compare the result of applying the MILP policy with value of the optimization criterion from MILP
    for (i, tr) in enumerate(traces)
        (r, u, alloc, action_seq, requests) = PMDPs.LP.MILP_hindsight_pricing(mg, tr)
        @test r == results.r[i]
    end

end
