module CountingProcesses

using Distributions
using StaticArrays
using Random

export _rand!


"""
Abstract type for memoryless random processes
"""
abstract type MemorylessCountingProcess end

"""
    rand(bp::MemorylessCountingProcess)
    
Sample the next event in the process (time or timestep AND outcome)

    rand(bp::MemorylessCountingProcess, t::Number)

Sample event at time t. Works only for memoryless processes.
"""
function rand end


# """
#     reset!(bp::MemorylessCountingProcess)

# Reset the state of the process to the start
# """
# function reset! end


 

# include("poisson_process.jl")
include("bernoulli_process.jl")

end
