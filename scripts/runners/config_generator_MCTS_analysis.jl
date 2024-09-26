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
# Prepare pricing problems and traces

"""

experiment_name = "ev_mcts_analysis"
OBJECTIVE = PMDPs.REVENUE
nᵣ = 12 # number of resources
demand_scaling_parameter = nᵣ

pp_params = Dict(pairs((
    nᵣ = nᵣ,
    c = 3,
    T = Int64(demand_scaling_parameter*8),
    demand_scaling_parameter = demand_scaling_parameter, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
    res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per HOUR of charging.
    objective = OBJECTIVE,
)))

pp = PMDPs.single_day_cs_pp(;pp_params...)


pp_config_fpath = MDPPricing.prepare_pricing_problem_config(experiment_name, PMDPs.single_day_cs_pp, pp_params)

# pp_config = PMDPs.parse_yaml_config("data/ev_test_experiments/single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0/pp_config.yaml")
# pp = pp_config[:pp_constructor](;pp_config[:pp_params]...)

N_traces = 100
traces_fpath = PMDPs.prepare_traces(pp_config_fpath, N_traces; seed = 888, verbose = true)

"""
# Generate solver configs

Full grid search over the following parameters:
- depth
- exploration_constant
- n_iterations
- reuse_tree

"""

"""
## ============= MCTS solver =============
"""

depth_range = [1,2,3,4,6,8,10,15,20,30,50]
exploration_constant_range = [0.5, 1.0, 2.0, 3.0, 4.0, 6.0, 8.0, 10.0]
n_iterations_range = [10, 30, 50, 80, 100, 1000, 10000]
reuse_tree_range = [true, false]

n_configs = length(depth_range)*length(exploration_constant_range)*length(n_iterations_range)*length(reuse_tree_range)

for (depth, ec, n_iter, reuse_tree) in Iterators.product(depth_range, exploration_constant_range, n_iterations_range, reuse_tree_range)
    solver_cfg = Dict(pairs((
        runner = PMDPs.mcts,
        seed = 1234,
        solver_params = Dict(
            pairs((
                depth=depth, # unlimited?
                exploration_constant=ec, # may bound error in the literature
                n_iterations=n_iter, # min pocet samplu
                reuse_tree=reuse_tree, 
                rng = MersenneTwister, # needs to be initialized from the seed when loading
            )),
        ),
    )))
    
    # traces_fpath = raw"data\ev_test_experiments\single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0\traces\traces_N=100_seed=888.jld2"
    MDPPricing.prepare_solver_config(traces_fpath, solver_cfg)
end

solver_cfg = Dict(pairs((
    runner = PMDPs.mcts,
    seed = 1234,
    solver_params = Dict(
        pairs((
            depth=1, # unlimited?
            exploration_constant=1.0, # may bound error in the literature
            n_iterations=100, # min pocet samplu
            reuse_tree=true, 
            rng = MersenneTwister, # needs to be initialized from the seed when loading
        )),
    ),
)))
MDPPricing.prepare_solver_config(traces_fpath, solver_cfg)
# solver_cfg_filepath = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_test_experiments\single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0\results\mcts\config_mcts_depth=4_exploration_constant=25.0_n_iterations=100_reuse_tree=true.yaml"

# res = PMDPs.run_solver(solver_cfg_filepath)

"""
## ============= Oracle solver =============
"""
solver_cfg = Dict(pairs((
    runner = PMDPs.hindsight,
    seed = 1234,
)))


solver_cfg_filepath = MDPPricing.prepare_solver_config(traces_fpath, solver_cfg)
# res = PMDPs.run_solver(solver_cfg_filepath)


"""
## ============= Flatrate solver =============
"""
solver_cfg = Dict(pairs((
    runner = PMDPs.flatrate,
    seed = 1234,
    flatrate_train_range_start = 1,
    flatrate_train_range_end = 100
)))


solver_cfg_filepath = MDPPricing.prepare_solver_config(traces_fpath, solver_cfg)
# res = PMDPs.run_solver(solver_cfg_filepath)





# path = raw"/home/mrkosja1/MDPPricing/data/ev_test_experiments/single_day_cs_pp_T=96_c=3_expected_res=12_nᵣ=12_res_budget_μ=2.0/results/flatrate/..\..\traces\traces_N=100_seed=888.jld2"

