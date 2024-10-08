using PMDPs
using Random
using DrWatson
using BSON

using POMDPTools # load histories
using Distributions # load

using LightGraphs
using GraphPlot
using Cairo, Compose

N_individ = 100
pps = [
    # Dict(pairs((nᵣ=3, c=3, T=10, demand_scaling_parameter=3., res_budget_μ=5.))),
    # Dict(pairs((nᵣ=6, c=5, T=100, demand_scaling_parameter=60., res_budget_μ=5.))),
    # Dict(pairs((nᵣ=10, c=5, T=100, demand_scaling_parameter=100., res_budget_μ=5.))),
    # Dict(pairs((nᵣ=10, c=40, T=1000, demand_scaling_parameter=Float64(800), res_budget_μ=5.))),
    # Dict(pairs((nᵣ=50, c=40, T=1000, demand_scaling_parameter=Float64(4000), res_budget_μ=5.)))
    # Dict(pairs((nᵣ=6, c=5, T=100, demand_scaling_parameter=60., res_budget_μ=5., objective=:utilization))),
    Dict(
        pairs((
            nᵣ = 3,
            c = 3,
            T = 10,
            demand_scaling_parameter = 3.0,
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            nᵣ = 10,
            c = 5,
            T = 100,
            demand_scaling_parameter = 100.0,
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            nᵣ = 10,
            c = 40,
            T = 1000,
            demand_scaling_parameter = Float64(800),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            nᵣ = 50,
            c = 40,
            T = 1000,
            demand_scaling_parameter = Float64(4000),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
]
name = "linear_problem"
for pp_params in pps
    display("Generating $name with $pp_params")
    pp = PMDPs.linear_pp(; pp_params...)
    mg = PMDPs.PMDPg(pp)

    rng = Xoshiro(1)
    traces = [PMDPs.simulate_trace(mg, rng) for i = 1:N_individ]

    sname = savename("traces_lp", pp_params, "bson")
    @tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces))
end


N_individ = 100
gpps = [
    Dict(
        pairs((
            NV = 5,
            NE = 8,
            seed = 1,
            NP = 20,
            c = 5,
            T = 100,
            demand_scaling_parameter = Float64(80),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            NV = 8,
            NE = 20,
            seed = 1,
            NP = 50,
            c = 10,
            T = 1000,
            demand_scaling_parameter = Float64(400),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            NV = 15,
            NE = 30,
            seed = 1,
            NP = 100,
            c = 10,
            T = 1000,
            demand_scaling_parameter = Float64(600),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
    Dict(
        pairs((
            NV = 30,
            NE = 45,
            seed = 1,
            NP = 100,
            c = 10,
            T = 1000,
            demand_scaling_parameter = Float64(900),
            res_budget_μ = 5.0,
            objective = :utilization,
        )),
    ),
]
name = "graph_problem"
for pp_params in gpps
    display("Generating $name with $pp_params")
    pp, g = PMDPs.graph_pp(; pp_params...)
    display(gplot(g, nodelabel = 1:nv(g)))

    #  https://juliapackages.com/p/graphplot
    draw(PNG(plotsdir(savename("graph_", pp_params, "png")), 16cm, 16cm), gplot(g))
    # mg = PMDPs.PMDPg(pp)

    # rng = Xoshiro(1)
    # traces = [PMDPs.simulate_trace(mg, rng) for i in 1:N_individ]

    # sname = savename("traces_gp", pp_params,  "bson")
    # @tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces, g))
end


const N = 100 # number of traces
# Linear instances
for demand_scaling_parameter = 50:50:1200
    pp_params = Dict(
        pairs((
            nᵣ = 10,
            c = 40,
            T = 1000,
            demand_scaling_parameter = Float64(demand_scaling_parameter),
            res_budget_μ = 5.0,
        )),
    )
    name = "linear_problem"
    display("Generating $name with $pp_params")
    pp = PMDPs.linear_pp(; pp_params...)
    mg = PMDPs.PMDPg(pp)

    rng = Xoshiro(1)
    traces = [PMDPs.simulate_trace(mg, rng) for i = 1:N]

    sname = savename("traces_lp", pp_params, "bson")
    @tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces))
end

# Graph instances
for seed = 1:10
    for demand_scaling_parameter = 25:25:600
        pp_params = Dict(
            pairs((
                NV = 8,
                NE = 20,
                seed = seed,
                NP = 50,
                c = 10,
                T = 1000,
                demand_scaling_parameter = Float64(demand_scaling_parameter),
                res_budget_μ = 5.0,
            )),
        )
        name = "graph_problem"
        display("Generating $name with $pp_params")
        pp, g = PMDPs.graph_pp(; pp_params...)
        mg = PMDPs.PMDPg(pp)

        rng = Xoshiro(1)
        traces = [PMDPs.simulate_trace(mg, rng) for i = 1:N]

        sname = savename("traces_gp", pp_params, "bson")
        @tagsave(datadir("traces", sname), @dict(name, pp, pp_params, traces, g))
    end
end
