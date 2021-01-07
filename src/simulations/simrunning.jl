using DataFrames
using RandomNumbers.Xorshifts
using DiscreteValueIteration
using ProgressMeter


function mcts(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; kwargs...)::DataFrame
    mg = PMDPg(pp)
    mcts = get_MCTS_planner(mg)
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
    flatrate = get_flatrate_policy(mg, [simulate_trace(mg, rnd) for i in 1:500])
    results = eval(mg, traces, @ntuple(flatrate), MersenneTwister(1))
end

function hindsight(pp::PMDPProblem, traces::AbstractArray{<:AbstractSimHistory}, rnd::AbstractRNG; kwargs...)::DataFrame
    mg = PMDPg(pp)
    results=DataFrame()
    @showprogress 1 "Computing hindsight" for (i, trace) in enumerate(traces)
        result = DataFrame    
        try    
            hindsight = LP.get_MILP_hindsight_policy(mg, trace)
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

function process_data(data::Dict, method::Function; info="", N=10000, kwargs=Dict())
    traces = data[:traces]
    pp = data[:pp]
    pp_params = data[:pp_params]
    rnd = Xorshift128Plus(1516)

    N>=length(traces) ? N=length(traces) : N=N
    traces = data[:traces]

    results = method(pp, traces, rnd; name=data[:name], pp_params=pp_params, kwargs...)    
    
    agg = describe(results, cols=1:4)
    
    result_dir = datadir("results", data[:name])
    mkpath(result_dir)
    fname = string(method, "_",  savename(@dict(N)), "_", savename(pp_params), info, ".bson")
    save(datadir("results", data[:name], fname), @dict(pp_params, results, agg))
    
    results
end
