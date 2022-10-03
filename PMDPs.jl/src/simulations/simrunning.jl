function mcts(
    pp::PMDPProblem,
    traces::AbstractArray{<:AbstractSimHistory},
    rng;
    solver = nothing,
    p::Union{Nothing, Progress}=nothing,
    kwargs...
)::DataFrame
    mg = PMDPg(pp)
    if solver !== nothing
        mcts = MCTS.solve(solver, mg)
    else
        mcts = get_MCTS_planner(mg)
    end
    results = eval_policy(mg, traces, @ntuple(mcts), rng; p=p)
end


function vi(
    pp::PMDPProblem,
    traces::AbstractArray{<:AbstractSimHistory},
    rng;
    name,
    pp_params,
    kwargs...
)::DataFrame
    me = PMDPe(pp)
    mg = PMDPg(pp)

    fname = string("vi_", savename(pp_params), "_", savename(kwargs))

    # vi = get_VI_policy(me)
    policydict, fpath = produce_or_load(
        datadir("vi_policies", name), # dir for output
        Dict(:mdp => me, :params => kwargs), # args for fun (has to be dict) 
        get_VI_policy; # fun, has to return dict
        prefix = fname
    )  # filename prefix

    vi = policydict["policy"]

    results = eval_policy(mg, traces, @ntuple(vi), rng)
end

function flatrate(
    pp::PMDPProblem,
    traces::AbstractArray{<:AbstractSimHistory},
    rng;
    train_range::UnitRange{Int64}=1:5,
    kwargs...
)::DataFrame
    mg = PMDPg(pp)
    println("train range $train_range")
    flatrate = get_flatrate_policy(mg, [simulate_trace(mg, rng) for i = train_range])
    results = eval_policy(mg, traces, @ntuple(flatrate), rng)
end

function fhvi(
    pp::PMDPProblem,
    traces::AbstractArray{<:AbstractSimHistory},
    rng; kwargs...
)::DataFrame
    me = PMDPe(pp)
    mg = PMDPg(pp)
    fhvi = get_FHVI_policy(me)
    results = eval_policy(mg, traces, @ntuple(fhvi), rng)
end


function hindsight(
    pp::PMDPProblem,
    traces::AbstractArray{<:AbstractSimHistory},
    rng;
    kwargs...
)::DataFrame
    lp_kwargs = Dict()
    try
        GRB_ENV = Gurobi.Env()
        gurobi = true
        lp_kwargs = @dict(gurobi, GRB_ENV)
    catch err
        @warn "Gurobi not available: $(err.msg) \n Using GLPK as an LP solver in hindsight benchmark instead."
        gurobi = false
        lp_kwargs = @dict(gurobi)
    end

    mg = PMDPg(pp)
    results = DataFrame()
    @showprogress 1 "Computing hindsight" for (i, trace) in enumerate(traces)
        result = DataFrame
        try
            hindsight = LP.get_MILP_hindsight_policy(mg, trace; lp_kwargs)
            result = eval_policy(mg, trace, @ntuple(hindsight), rng)
        catch err
            @error "Error processing $i th trace: $err"
            showerror(stderr, err, catch_backtrace())
            result = DataFrame(name = "hindsight", sequence = hash(trace), error = err)
        end
        results = vcat(results, result, cols = :union)
    end
    results
end

function process_data(
    data::Dict,
    method::Function;
    folder = "",
    info = "",
    method_info = "",
    solver_params=Dict(),
    n = 1,
    N = 10000,
    rng=Xorshift128Plus(1516),
    kwargs...
)
    traces = data[:traces]
    pp = data[:pp]
    pp_params = data[:pp_params]

    N >= length(traces) ? N = length(traces) : N = N
    traces = data[:traces][n:N]

    results, overall_stats... =
        @timed method(pp, traces, rng; name = data[:name], pp_params = pp_params, kwargs...)

    agg = describe(results, cols = [:r, :u, :nₛ, :nᵣ, :time, :bytes])

    result_dir = datadir("results", data[:name])
    mkpath(result_dir)
    method_name = string(method, method_info)
    fname = string(
        method_name,
        "_",
        savename(@dict(N)),
        "_",
        savename(pp_params),
        info,
        ".jld2",
    )
    problem_name = data[:name]
    method = string(method)
    save(
        datadir(folder, "results", problem_name, fname),
        Dict("jld2_data"=>@dict(
            pp_params,
            problem_name,
            info,
            method,
            method_info,
            results,
            agg,
            overall_stats,
            N,
            solver_params,
            kwargs
        ))
    )
    results
end

function prepare_traces(
    pp::PMDPs.PMDPProblem,
    pp_params::Dict,
    vi::Bool,
    name::String,
    N::Int64;
    folder = "test_traces",
    seed = 1,
    verbose = false,
    save = true,
)
    mg = PMDPs.PMDPg(pp)
    rng = Xorshift128Plus(seed)
    fname = savename("$(name)_N=$(N)", pp_params, "jld2")
    fpath = datadir(folder, "traces", fname)

    if isfile(fpath)
        verbose ? println("Loading $fpath") : nothing
        data = PMDPs.load_tagsaved_jld2_traces(fpath)
    else
        traces = [PMDPs.simulate_trace(mg, rng) for i = 1:N]
        data = @dict(name, pp, pp_params, traces, vi)
        if save
            verbose ? println("Saving $fpath") : nothing
            @tagsave(fpath, Dict("jld2_data"=>data))
        end
    end
    return data
end