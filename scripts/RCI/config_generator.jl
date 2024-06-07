using PMDPs
using Random
using DrWatson
using ProgressMeter
using Logging

include(srcdir("MDPPricing.jl"))
using .MDPPricing

"""
Generate experiment configuration in YAML format.

There will be multilple types of configs:

inputs:

 - pp_params: parameters of the pricing problem
 - traces: parameters of the traces generated from the pricing problem

solutions:
 
 - mcts: parameters of the MCTS solver
 - flatrate: parameters of the flatrate solver
 - oracle: parameters of the oracle solver

directory_structure:
 
 - 📂experiment_name: top level directory, user determined
   - 📂pp_name: directory for the pricing problem that fully determines pricing problem
     - 📄pp_config.yaml: configuration of the pricing problem
     - 📂traces: directory for the traces generated from the pricing problem
       - 📄config_1.yaml
       - 📦traces_1.jld2
     - 📂results: directory for the results of the pricing problem
       - 📂mcts: directory for the results of the MCTS solver
         - 📄config_1.yaml
         - 📦mcts_1-depth=2-n_iterations=2.jld2:  summary results, most important parametets in the name
         - 📒mcts_1_raw.jld2: raw results on the level of individual traces
       - 📂flatrate: directory for the results of the flatrate solver
         - 📄config_1.yaml: configuration of the flatrate solver
         - 📦flatrate_1.jld2
         - 📒flatrate_1_raw.jld2 
       - 📂oracle: directory for the results of the oracle solver 
         - 📄config.yaml
         - 📦oracle_1.jld2
         - 📒oracle_1_raw.jld2
         
WORKFLOW:

1. Generate the pricing problem and traces
2. Generate the solver configs
3. Run the solvers on the cluster

Issues:
 - config filenames should be expressive and unique, so they should cover all of the contained info?
    - so manually editing configs should be discouraged?
    - SOLUTION: most important config parts should be in the name, concluded by the timestap of creation. Manual editing should be discouraged.
 - 
"""


experiment_name = "ev_test_experiments"
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





prepare_pricing_problem_config(experiment_name, PMDPs.single_day_cs_pp, pp_params)

pp_config = PMDPs.parse_yaml_config("data/ev_test_experiments/single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0/pp_config.yaml")
pp = pp_config[:pp_constructor](;pp_config[:pp_params]...)

PMDPs.prepare_traces("data/ev_test_experiments/single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0/pp_config.yaml", 100; seed = 888, verbose = true)


# Generate solver configs

solver_cfg = Dict(pairs((
    runner = PMDPs.mcts,
    seed = 1234,
    solver_params = Dict(
        pairs((
            depth=1, # unlimited?
            exploration_constant=25.0, # may bound error in the literature
            n_iterations=100, # min pocet samplu
            reuse_tree=true, # probably not
            rng = MersenneTwister, # needs to be initialized from the seed when loading
        )),
    ),
)))
traces_filepath = raw"data\ev_test_experiments\single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0\traces\traces_N=100_seed=888.jld2"
prepare_solver_config(traces_filepath, solver_cfg)

solver_cfg_filepath = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_test_experiments\single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0\results\mcts\config_mcts_depth=4_exploration_constant=25.0_n_iterations=100_reuse_tree=true.yaml"

res = PMDPs.run_solver(solver_cfg_filepath)


solver_cfg = Dict(pairs((
    runner = PMDPs.hindsight,
    seed = 1234,
)))

traces_filepath = raw"data\ev_test_experiments\single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0\traces\traces_N=100_seed=888.jld2"
solver_cfg_filepath = prepare_solver_config(traces_filepath, solver_cfg)
res = PMDPs.run_solver(solver_cfg_filepath)


solver_cfg = Dict(pairs((
    runner = PMDPs.flatrate,
    seed = 1234,
    flatrate_train_range_start = 1,
    flatrate_train_range_end = 100
)))

traces_filepath = raw"data\ev_test_experiments\single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0\traces\traces_N=100_seed=888.jld2"
solver_cfg_filepath = prepare_solver_config(traces_filepath, solver_cfg)
res = PMDPs.run_solver(solver_cfg_filepath)



