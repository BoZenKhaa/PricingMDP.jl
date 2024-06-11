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

function prepare_pricing_problem_config(experiment_name::String, pp_constructor, pp_params::Dict)
    pp_name = savename(String(Symbol(pp_constructor)),pp_params)
    path = datadir(experiment_name, pp_name)
    mkpath(path)
    cfg = Dict(pairs((
        pp_name = pp_name,
        pp_constructor = pp_constructor,
        pp_params = pp_params,))
    )
    config_fpath = joinpath(path, "pp_config.yaml") 
    save_yaml_config(config_fpath, cfg)
    return config_fpath
end

function prepare_solver_config(traces_filepath::String, solver_cfg::Dict)
    cfg_name = savename("config_$(Symbol(solver_cfg[:runner]))", get(solver_cfg, :solver_params, nothing))
    cfg_folder = abspath(joinpath(splitpath(traces_filepath)[1:end-2]...,"results",String(Symbol(solver_cfg[:runner]))))
    mkpath(cfg_folder)
    traces_relpath = relpath(abspath(traces_filepath), cfg_folder)
    solver_cfg[:traces] = traces_relpath
    config_path = joinpath(cfg_folder, "$(cfg_name).yaml")
    save_yaml_config(config_path, solver_cfg)
    return config_path
end
