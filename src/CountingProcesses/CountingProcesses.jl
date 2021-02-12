module CountingProcesses

using Distributions
using StaticArrays
using Random

export DiscreteCountingProcess, BernoulliScheme, StaggeredBernoulliScheme, NonhomogenousBernoulliScheme

include("poisson_process.jl")
include("bernoulli_process.jl")
include("bernoulli_scheme.jl")
include("staggered_bernoulli_scheme.jl")
include("nonhomgen_bernoulli_scheme.jl")

end
