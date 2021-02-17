function mcts(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; mcts_solver = nothing, kwargs...)::DataFrame
    mg = PMDPg(pp) 
    if mcts_solver != nothing
        display("using custom MCTS planner: $mcts_solver)")
        mcts = MCTS.solve(mcts_solver, mg)
    else
        mcts = get_MCTS_planner(mg)
    end
    results = eval(mg, traces, @ntuple(mcts), MersenneTwister(1))
end


function vi(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; name, pp_params, kwargs...)::DataFrame
    me = PMDPe(pp)
    mg = PMDPg(pp)

    fname = string("vi_", savename(pp_params), "_", savename(kwargs))
    
    # vi = get_VI_policy(me)
    policydict, fpath =  produce_or_load(datadir("vi_policies", name), # dir for output
                                Dict(:mdp=>me, :params=>kwargs), # args for fun (has to be dict) 
                                get_VI_policy; # fun, has to return dict
                                prefix=fname)  # filename prefix

    vi = policydict[:policy]

    results = eval(mg, traces, @ntuple(vi), MersenneTwister(1))
end

function flatrate(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; kwargs...)::DataFrame
    mg = PMDPg(pp)
    flatrate = get_flatrate_policy(mg, [simulate_trace(mg, rnd) for i in 1:5])
    results = eval(mg, traces, @ntuple(flatrate), MersenneTwister(1))
end

function fhvi(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; kwargs...)::DataFrame
    me = PMDPe(pp)
    mg = PMDPg(pp)
    fhvi = get_FHVI_policy(me)
    results = eval(mg, traces, @ntuple(fhvi), MersenneTwister(1))
end


function hindsight(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; kwargs...)::DataFrame
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
    results=DataFrame()
    @showprogress 1 "Computing hindsight" for (i, trace) in enumerate(traces)
        result = DataFrame    
        try    
            hindsight = LP.get_MILP_hindsight_policy(mg, trace; lp_kwargs)
            result = eval(mg, trace, @ntuple(hindsight), MersenneTwister(1))
        catch err
            @error "Error processing $i th trace: $err"
            showerror(stderr, err, catch_backtrace())
            result = DataFrame(name="hindsight", sequence=hash(trace), error=err)            
        end
        results = vcat(results, result, cols=:union)
    end
    results
end

function process_data(data::Dict, method::Function; folder="", info="", method_info="", N=10000, kwargs...)
    traces = data[:traces]
    pp = data[:pp]
    pp_params = data[:pp_params]
    rnd = Xorshift128Plus(1516)

    N>=length(traces) ? N=length(traces) : N=N
    traces = data[:traces][1:N]

    results = method(pp, traces, rnd; name=data[:name], pp_params=pp_params, kwargs...)    
    
    agg = describe(results, cols=1:4)
    
    result_dir = datadir("results", data[:name])
    mkpath(result_dir)
    method_name = string(method, method_info)
    fname = string(method_name, "_",  savename(@dict(N)), "_", savename(pp_params), info, ".bson")
    save(datadir("results",folder, data[:name], fname),
         @dict(pp_params, data[:name], info, string(method), method_info, results, agg, N, kwargs)
        )
    results
end
