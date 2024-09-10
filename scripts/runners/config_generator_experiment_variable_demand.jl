using PMDPs
using Random
using DrWatson
using ProgressMeter
using Logging

include(srcdir("MDPPricing.jl"))
using .MDPPricing


"""
# Experiments for the pricing paper:

1. Test MCTS
2. Experiments:
    - Variable demand
    - Variable discretization
      - Variable discretization - number of timesteps
      - Variable discretization - number of resources - HOW?? Not yet?


"""


"""
Approximation Error metrtics

λ .... expected number of arrivals = expected res
k .... number of timesteps = T
"""
err₁(λ, k) =  k - (k+λ)*(exp(-λ/k))
err₂(λ, k) =  λ*exp(-λ/k) + (λ-k)*(1-exp(-λ/k))
err(λ, k) = err₂(λ, k)/λ

# nᵣ_vals = [2, 3, 4, 6, 8, 10, 12, 16, 20, 24, 30, 36, 42, 48, 60, 72, 84, 96]#, 120, 144, 168, 192, 240]

experiment_name = "ev_variable_demand"
OBJECTIVE = PMDPs.REVENUE


# for nᵣ in nᵣ_vals
#     # nᵣ = 2 # number of resources
#     expected_res = 3*nᵣ

#     pp_params = Dict(pairs((
#         nᵣ = nᵣ,
#         c = 3,
#         T = Int64(expected_res*8),
#         expected_res = expected_res, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
#         res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
#         objective = OBJECTIVE,
#     )))

#     @show nᵣ,  err(expected_res, pp_params[:T])

#     pp = PMDPs.single_day_cs_pp(;pp_params...)
# end


"""
# Prepare pricing problems and traces

"""

for demand_multiplier in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    nᵣ = 24
    # nᵣ = 2 # number of resources
    expected_res = demand_multiplier*nᵣ

    pp_params = Dict(pairs((
        nᵣ = nᵣ,
        c = 3,
        T = Int64(expected_res*8),
        expected_res = expected_res, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
        res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
        objective = OBJECTIVE,
    )))

    pp = PMDPs.single_day_cs_pp(;pp_params...)


    pp_config_path = prepare_pricing_problem_config(experiment_name, PMDPs.single_day_cs_pp, pp_params)

    pp_config = PMDPs.parse_yaml_config(pp_config_path)
    pp = pp_config[:pp_constructor](;pp_config[:pp_params]...)


    N_traces = 100
    traces_fpath = PMDPs.prepare_traces(pp_config_path, N_traces; seed = 888, verbose = true)

    """
    # Generate solver configs



    """

    """
    ## ============= MCTS solver =============
    """
    solver_cfg = Dict(pairs((
        runner = PMDPs.mcts,
        seed = 1234,
        solver_params = Dict(
            pairs((
                depth=3, # unlimited?
                exploration_constant=3.0, # may bound error in the literature
                n_iterations=10000, # min pocet samplu
                reuse_tree=false, # probably not
                rng = MersenneTwister, # needs to be initialized from the seed when loading
            )),
        ),
    )))

    solver_cfg_filepath = MDPPricing.prepare_solver_config(traces_fpath, solver_cfg)
    # res = PMDPs.run_solver(solver_cfg_filepath)

    """
    ## ============= Oracle solver =============
    """
    solver_cfg = Dict(pairs((
        runner = PMDPs.hindsight,
        seed = 1234,
    )))


    solver_cfg_filepath = prepare_solver_config(traces_fpath, solver_cfg)
    # res = PMDPs.run_solver(solver_cfg_filepath)


    """
    ## ============= Flatrate solver =============
    """
    solver_cfg = Dict(pairs((
        runner = PMDPs.flatrate,
        seed = 1234,
        flatrate_train_range_start = 1,
        flatrate_train_range_end = 25
    )))

    solver_cfg_filepath = prepare_solver_config(traces_fpath, solver_cfg)
    # res = PMDPs.run_solver(solver_cfg_filepath)

    """
    ## ============= VI =============
    """
    solver_cfg = Dict(pairs((
        runner = PMDPs.vi,
        solver_params = Dict(
            pairs((            
                max_iterations=100, 
                belres=1e-6, 
                verbose=true,
            )),
        ),
        seed = 1234, # needed here even though VI does not use this
    )))

    solver_cfg_filepath = prepare_solver_config(traces_fpath, solver_cfg)
    # res = PMDPs.run_solver(solver_cfg_filepath)
end


# path = raw"/home/mrkosja1/MDPPricing/data/ev_test_experiments/single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0/results/flatrate/..\..\traces\traces_N=100_seed=888.jld2"

