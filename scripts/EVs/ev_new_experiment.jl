using PMDPs
using Random
using DrWatson
using ProgressMeter
using MCTS

include(srcdir("MDPPricing.jl"))
using .MDPPricing


"""
 # Problem configuration
"""

err₁(λ, k) =  k - (k+λ)*(exp(-λ/k))
err₂(λ, k) =  λ*exp(-λ/k) + (λ-k)*(1-exp(-λ/k))

RNG = MersenneTwister
rng_seed =  687321
rng=RNG(rng_seed)

OBJECTIVE = PMDPs.REVENUE
nᵣ = 12 # number of resources
expected_res = nᵣ
pp_params = Dict(pairs((
                nᵣ = nᵣ,
                c = 3,
                T = Int64(expected_res*8),
                expected_res = expected_res, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
                res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
                objective = OBJECTIVE,
            )))

pp = PMDPs.single_day_cs_pp(;pp_params...)

k = PMDPs.CountingProcesses.n_steps(pp.D)
λ = pp.D.inter_arrival_time.p*k

@show err₁(λ, k),  err₂(λ, k), err₂(λ, k)/λ
@assert  err₂(λ, k)/λ < 0.1

"""
 # Prepare traces
"""
inputs = []
OUT_FOLDER = datadir("ev_new_experiments")
PP_NAME = "cs_$(nᵣ)"

vi = false
name = PP_NAME
n_traces = 10
seed = 8888
traces_verbose=true

inputs = push!(inputs, PMDPs.prepare_traces(pp, pp_params, vi, name, n_traces; verbose=traces_verbose, folder = OUT_FOLDER, seed=seed, save=true))

@info "'inputs' size is $(Base.summarysize(inputs)/1000/1000) MB"

"""
 # Solvers ans solutions
 ## MCTS
"""

N_traces=n_traces
e_inputs = collect(enumerate(inputs[1:end]))

println("Total of inputs: $(length(e_inputs))")

n_threads = Threads.nthreads()
# mcts_seed = 7987
params_classical_MCTS = Dict(
    pairs((
        depth=4, # unlimited?
        exploration_constant=25.0, # may bound error in the literature
        n_iterations=10_000, # min pocet samplu
        reuse_tree=true, # probably not
        rng=RNG(seed),
    )),
)


for d in [3,]
    for data in inputs
        params = deepcopy(params_classical_MCTS)
        params[:depth] = d
        p=Progress(length(e_inputs)*N_traces, desc="All MCTS:", color=:red)
        solver = MCTSSolver(;params...)
        PMDPs.process_data(
            data,
            PMDPs.mcts;
            result_fpath = joinpath(OUT_FOLDER, "test_mcts" ),
            folder = OUT_FOLDER,
            n = 1,
            N = N_traces,
            method_info = "vanilla_$(savename(params))",
            solver = solver,
            solver_params  = params,
            rng=RNG(seed),
            p=p,
        )
    end
end


"""
 # flatrate and oracle
"""
flatratae_train_range = 1:round(Int64, N_traces/100*25)
# flatrate_seed = 7898

for (i, data) in e_inputs
    println("flatrate...")
    PMDPs.process_data(data, PMDPs.flatrate; folder = OUT_FOLDER, N = N_traces,  train_range=flatratae_train_range, rng=RNG(seed))
end

# oracle_seed = 7899
for (i, data) in e_inputs
    """
    To run in parallel with suppressed output
    https://stackoverflow.com/questions/64844626/julia-1-5-2-suppressing-gurobi-academic-license-in-parallel
    """
    println("Oracle...")
    PMDPs.process_data(data, PMDPs.hindsight; folder = OUT_FOLDER, N = N_traces, rng=RNG(seed))
end


"""
 # Collect results
"""

@show results, raw = folder_report(datadir(OUT_FOLDER, "results", PP_NAME); raw_result_array = true)

"""
 # Analyze and plot results
"""

results

# get column names 
names(results)

results.mean_r

