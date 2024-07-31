# PricingMDP

[![Build Status](https://travis-ci.com/BoZenKhaa/PricingMDP.jl.svg?branch=master)](https://travis-ci.com/BoZenKhaa/PricingMDP.jl)
[![Coverage](https://codecov.io/gh/BoZenKhaa/PricingMDP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BoZenKhaa/PricingMDP.jl)

This code base is using the Julia Language and [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> PricingMDP

It is authored by Jan Mrkos.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box.


## Running experiments on RCI

Assuming the project is already cloned on RCI, run the experiments according to this checklist:

0. [ ] **prepare experiment configs** - copy the script `scripts/RCI/config_generator` and edit it to generate scripts for required experiments. Run or REPL the script to prepare the configs. 

1. [ ] **sync code to the RCI cluster** - pull in the latest changes from git. Do this by `ssh rci_amd` from WSL where the ssh agent forwarding works. In the RCI terminal, run `ml purge` to clear the modules that are breaking TLS and preventing `git pull` from working. Do not forget to commit/push the submodules! Use VS code to check the changes are commited. 

2. [ ] **sync experiment configs to the RCI cluster** - use WinSCP to copy the configs in the `data` folder to the `/mnt/data/mobility/MDPPricing/data` folder on the RCI cluster.

3. [ ] **run the experiments** - connect to the RCI cluster with Jetbrains Gateway to run the Python scripts. Use `Python/run_experiments_batch.py` to launch the experiments. Start with the following options: 
```bash
--experiments_path=/home/mrkosja1/MDPPricing/data/ev_variable_resources
--dry_run # check the commands that will be run
--log="" # log into console instead of a file
```

4. [ ] **Keep track of experiments** You can use following to check on the status of your jobs:
      ```bash
      watch --color -n .5 'squeue -o  "%.18i %.9P %80j %.8u %.2t %.10M %.6D %R" | grep mrkos | tail -n $(($LINES - 2))'
      ```
Use `Python/check_unfinished_jobs.py` to get a list of jobs that did not finish. 
Rerun experiments with option
```bash
--config_paths_from_file=/home/mrkosja1/MDPPricing/Python/scripts/unfinished_runs.txt
``` 

5. [ ] **sync results from the RCI cluster** - use WinSCP to copy the results from the RCI cluster to the local machine.

6. [ ] **commit and push any code changes made on the cluster** - use the ssh from WSL, similar to the step 1.