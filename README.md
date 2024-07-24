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
1. [ ] **sync code to the RCI cluster** - pull in the latest changes from git. Do this by `ssh rci_amd` from WSL where the ssh agent forwarding works. In the RCI terminal, run `ml purge` to clear the modules that are breaking TLS and preventing `git pull` from working.
2. [ ] **sync experiment configs to the RCI cluster** - use WinSCP to copy the configs in the `data` folder to the RCI cluster.
3. [ ] **run the experiments** - connect to the RCI cluster with VS code. Run the experiments from the VS code terminal.
4. [ ] **sync results from the RCI cluster** - use WinSCP to copy the results from the RCI cluster to the local machine.
5. [ ] **commit and push any code changes made on the cluster** - use the ssh from WSL, similar to the step 1.