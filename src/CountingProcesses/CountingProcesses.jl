module CountingProcesses

using Distributions
using StaticArrays
using Random

export DiscreteCountingProcess, BernoulliScheme

include("poisson_process.jl")
include("bernoulli_process.jl")

end
