using JLD2
using PMDPs

exp_dir = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\tmp_investigating_flatrate"
solver_cfg_pathfile = joinpath(exp_dir, "results", "flatrate", "config_flatrate.yaml")




PMDPs.run_solver(solver_cfg_pathfile)