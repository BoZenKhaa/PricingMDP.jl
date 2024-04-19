using PMDPs
using Random
using DrWatson
import YAML
import JLD2
using StaticArrays

include(srcdir("MDPPricing.jl"))

# Generate instance configs

bm = MDPPricing.get_tiny_benchmarks()

typeof(bm[1])

YAML.write_file(datadir("test.yaml"), pairs(bm[1]))

PMDPs.Action
PMDPs.PMDPg{State, Action, PP<:PMDPProblem} <: PMDP{State, Action}
PMDPs.PMDP

actions

# p = YAML.load_file(datadir("test.yaml"), dicttype=Dict{Symbol,Any})