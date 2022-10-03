using PMDPs
using POMDPs

using StaticArrays
using Distributions
using DiscreteValueIteration
using Printf
using Random

using D3Trees
# using AbstractTrees
# using Colors

using PMDPs.CountingProcesses
using RandomNumbers.Xorshifts

using BenchmarkTools
using Distributions

# Benchmark on simple pricing problem

function simple_pp()
    T=20
    P = [
        PMDPs.Product([true, false], T), # 1
        PMDPs.Product([false, true], T-2), # 2
        PMDPs.Product([true, true], T-2),
    ]  # 3
    C₀ = [2, 2]
    D = BernoulliScheme(T, [0.08, 0.12, 0.06])
#     β₁ = DiscreteNonParametric([0.0, 5.0, 10.0 ], [0.1, 0.6, 0.3])
#     β₂ = DiscreteNonParametric([0.0, 5.0, 10.0, 15.0, 20.0], [0.1, 0.2, 0.4, 0.2, 0.1])
    β₁ = Normal(9, 5)
    β₂ = Normal(20, 2)
    B = [β₁, β₂, β₁]
    A = collect(0.:5.:25.) #[0.0, 5.0, 10.0, 15.0, 20.0]
    objective = :revenue

    pp = PMDPs.PMDPProblem(P, C₀, D, B, A, objective)
end

pp = simple_pp();
mg, me = PMDPs.PMDPg(pp), PMDPs.PMDPe(pp);

RNG = Xorshift1024Plus

params_classical_MCTS = Dict(
    pairs((
        depth = 10,
        exploration_constant = 10.,
        n_iterations = 1000,
        enable_tree_vis=true,
        reuse_tree = false,
    )),
)

solver = PMDPs.MCTS.MCTSSolver(; params_classical_MCTS..., rng = RNG(1), sizehint=100_000)
planner = PMDPs.MCTS.solve(solver, mg);
s₀ = rand(initialstate(me))

sp = PMDPs.State([2,2],2,2)

a = POMDPs.action(planner, sp)

GC.enable_logging(false)

@benchmark POMDPs.action($planner, $sp)


function benchmark_action_setup(mg)
    RNG = Xorshift1024Plus

    solver = PMDPs.MCTS.MCTSSolver(;
        depth = 10,
        exploration_constant = 10.,
        n_iterations = 1000,
        enable_tree_vis=true,
        reuse_tree = false, 
        rng = RNG(1), 
        estimate_value=PMDPs.MCTS.RolloutEstimator(PMDPs.MCTS.RandomSolver(RNG(1))),
        sizehint=100_000)
    
    planner = PMDPs.MCTS.solve(solver, mg)
    sp = PMDPs.State([2,2],2,2)
    return planner, sp
end

t = @benchmark POMDPs.action(inputs...) setup=(inputs = benchmark_action_setup($mg)) gcsample=false gctrial=true
maximum(t)
dump(t)

@benchmark benchmark_action($mg)

@benchmark POMDPs.action($(PMDPs.MCTS.solve(PMDPs.MCTS.MCTSSolver(; params_classical_MCTS..., rng = MersenneTwister(1), estimate_value=PMDPs.MCTS.RolloutEstimator(PMDPs.MCTS.RandomSolver(MersenneTwister(1)))), mg)), $sp)