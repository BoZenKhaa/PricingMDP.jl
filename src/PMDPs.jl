module PMDPs

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random
using Distributions
using Combinatorics

import Base.show

# Counting processes submodule
include("CountingProcesses/CountingProcesses.jl")

using .CountingProcesses
#Model definition
# export PMDP, PMDPg, State, Action
include("PMDP/PMDPTypes.jl")
include("PMDP/PMDPProblem.jl")
include("PMDP/State.jl")
include("PMDP/PMDP.jl")
include("PMDP/PMDPg.jl")
# include("PMDP/PMDPe.jl")


#Tools for defining problem instances
# include("problem_definition/graph.jl")
# include("problem_definition/product.jl")
# include("problem_definition/demand.jl")
# include("problem_definition/user_budgets.jl")

# # Simulation tools
# export run_sim, get_stats, makesim, simulate_trace
# include("simulations/simtools.jl")
# include("simulations/experiments.jl")
# include("simulations/trace_generation.jl")

# # evaluators
# include("eval/HistoryReplayer.jl")
# include("eval/evaluation.jl")

# # Policies
# include("policies/policy_tools.jl")
# include("policies/flatrate_baseline.jl")
# module LP
# include("policies/LP.jl")
# end

# # Problem definitions
# include("problem_instances/linear_problem.jl")

end
