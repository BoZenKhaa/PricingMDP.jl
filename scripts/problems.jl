using PMDPs

function linear_params(objective)
    [
        Dict(pairs((nᵣ=3, c=1, T=10, expected_res=6., res_budget_μ=5., 
            objective=objective))),
        Dict(pairs((nᵣ=5, c=2, T=40, expected_res=30., res_budget_μ=5., 
            objective=objective))), # last VI size to run
        Dict(pairs((nᵣ=10, c=5, T=100, expected_res=100., res_budget_μ=5., 
            objective=objective))),
        Dict(pairs((nᵣ=10, c=40, T=1000, expected_res=Float64(800), res_budget_μ=5., 
            objective=objective))),
        # Dict(pairs((nᵣ=50, c=40, T=1000, expected_res=Float64(4000), res_budget_μ=5., 
        #     objective=objective)))
    ]
end

function graph_params(objective)
    [
        Dict(pairs((NV=5, NE=8, seed=1, NP=20, c=5, T=100, expected_res=Float64(80), 
            res_budget_μ=5., objective=objective))), 
        Dict(pairs((NV=8, NE=20, seed=1, NP=50, c=10, T=1000, expected_res=Float64(400), 
            res_budget_μ=5., objective=objective))),
        Dict(pairs((NV=15, NE=30, seed=1, NP=100, c=10, T=1000, expected_res=Float64(600), 
            res_budget_μ=5., objective=objective))),
        # Dict(pairs((NV=30, NE=45, seed=1, NP=100, c=10, T=1000, expected_res=Float64(900), 
        #     res_budget_μ=5., objective=objective)))
    ]
end

function get_linear_problems(objective::Symbol)
    pps = [(pp=PMDPs.linear_pp(;pp_params...), params=pp_params) 
        for pp_params in linear_params(objective)]
end

function get_graph_problems(objective::Symbol)
    pps = [(pp=PMDPs.graph_pp(;pp_params...), params=pp_params) 
        for pp_params in graph_params(objective)]
end

function get_benchmarks(;objectives=(:revenue, :utilization), n_lp=100, n_gp=100)
    problems=[]
    for obj in objectives
        lpps = get_linear_problems(obj)
        gpps = get_graph_problems(obj)
        push!(problems, lpps[1:minimum([n_lp, length(lpps)])]...)
        push!(problems, gpps[1:minimum([n_gp, length(gpps)])]...)
    end
    problems
end

function get_fast_benchmarks()
    get_benchmarks(; n_lp=3, n_gp=3)
end

linear_params(:revenue)
graph_params(:revenue)

get_linear_problems(:revenue)
get_graph_problems(:revenue)

get_benchmarks()
fb = get_fast_benchmarks()

fb[1].params


# get_linear_problems(:revenue)
# get_graph_problems(:revenue)