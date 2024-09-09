using PMDPs

for (root, dirs, files) in walkdir(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources")
    if length(files)>0
        for file in files
            if file=="config_flatrate.yaml"
                solver_cfg_filepath = joinpath(root, file)
                println(solver_cfg_filepath)
                res = PMDPs.run_solver(solver_cfg_filepath)
            end
        end
    end
end
