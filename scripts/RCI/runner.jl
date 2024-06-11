#!/usr/bin/env julia
using Pkg
Pkg.activate(joinpath(@__DIR__, "../.."))
# Pkg.resolve() #Optional if a known-good Manifest.toml is included
# Pkg.instantiate()

using PMDPs

solver_cfg_pathfile = ARGS[1]
print("[runner.jl] Running solver on "*solver_cfg_pathfile)
PMDPs.run_solver(solver_cfg_pathfile)

