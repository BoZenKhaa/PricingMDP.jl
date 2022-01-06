using PMDPs
using PMDPs.LP
using DrWatson
using RandomNumbers.Xorshifts
using MCTS
using POMDPSimulators
using POMDPPolicies
using DiscreteValueIteration

using Formatting

import Base.show

using Plots
using Distributions
using ProgressMeter


using POMDPs

function Base.show(io::IO, ::MIME"text/plain", trace::SimHistory)
    for step in trace
        print(io, step.s)
        action = step.a
        budget = step.info.b
        printfmt(io, " b:{: 6.2f}", budget)
        printfmt(io, " a:{: 6.2f}", action)

        outcome, color = PMDPs.user_buy(action, budget) ? ("buy", :green) : ("not", :red)
        print(" -> ")
        printstyled(io, "$(outcome)"; color=color)
        print("\t")
        print(io, step.s)
        print(io, "\n")
    end
end

RND = Xorshift1024Plus

include(srcdir("MDPPricing.jl"))

pp = PMDPs.linear_pp(2; c = 2, T = 8)
mg = PMDPs.PMDPg(pp)
me = PMDPs.PMDPe(pp)

run(`clear`)
trace2 = PMDPs.simulate_trace(mg, RND(4))
for i = 1:10
    trace1 = PMDPs.simulate_trace(mg, RND(4))
    if ~isequal(trace1, trace2)
        display(trace1)
        display(trace2)
        print("======================")
    end
    trace2 = PMDPs.simulate_trace(mg, RND(4))
end


params_dpw = Dict(
    pairs((
        solver = DPWSolver,
        depth = 50,
        exploration_constant = 40.0,
        enable_state_pw = false,
        keep_tree = true,
        show_progress = false,
        rng = RND(1),
    )),
)

params_classical_MCTS = Dict(
    pairs((
        solver = MCTSSolver,
        depth = 15,
        exploration_constant = 40.0,
        reuse_tree = true,
        rng = RND(1),
    )),
)

# dpw_solver_params = (;depth=50, 
#     exploration_constant=40.0, max_time=1.,
#     enable_state_pw = false, 
#     keep_tree=true, show_progress=false, rng=Xorshift128Plus())

params_mcts=params_classical_MCTS

"""
Check stability of value iteration solver. Does the policy change with increasing number of iterations?
"""

for max_iter = [10,50,100,300,500, 1000]
    solver = SparseValueIterationSolver(max_iterations = max_iter, belres = 1e-12, verbose = false)#, init_util=init_util) # creates the solver
    # POMDPs.@show_requirements POMDPs.solve(solver, me)
    vi = DiscreteValueIteration.solve(solver, me)
    using DataStructures
    c = counter([vi.action_map[iₐ] for iₐ in vi.policy])
    display(c)
end

"""
Check stability of the MCTS, does it return vastly different actions for different seeds on the same trace?
"""

# mcts = PMDPs.get_MCTS_planner(mg, params_mcts = params_mcts) # without deepcopy of params, the seed is NOT the same for different runs
# # PMDPs.eval_policy(mg, [trace], @ntuple(mcts), MersenneTwister(1))
# hrpl = PMDPs.HistoryReplayer(mg, trace)
# mcts_trace2 = PMDPs.replay(hrpl, mcts, RND(1))


metrics = []

@showprogress 1 for c in 0:0.5:10.
    params_classical_MCTS = Dict(
        pairs((
            solver = MCTSSolver,
            depth = 15,
            exploration_constant = c,
            reuse_tree = true,
            rng = RND(1),
        )),
    )

    # dpw_solver_params = (;depth=50, 
    #     exploration_constant=40.0, max_time=1.,
    #     enable_state_pw = false, 
    #     keep_tree=true, show_progress=false, rng=Xorshift128Plus())

    params_mcts=params_classical_MCTS

    solver = SparseValueIterationSolver(max_iterations = 300, belres = 1e-12, verbose = false)
    vi = DiscreteValueIteration.solve(solver, me)
    qΔ = []
    n_a_diff = 0
    n_a_inf_diff = 0
    qΔ_inf = []
    verbose=false
    n_actionable_events=[]
    N_TRACES = 2000
    N_TRACE_REPETITIONS = 1
    for trace_seed in 1:N_TRACES
        trace = PMDPs.simulate_trace(mg, RND(trace_seed)) # same trace

        vi_hrpl = PMDPs.HistoryReplayer(me, trace)
        vi_trace=PMDPs.replay(vi_hrpl, vi, RND(1))

        if verbose
            run(`clear`)
            display(trace)
            println("==========COMPARISON============")
        end
        s = missing

        push!(n_actionable_events,  N_TRACE_REPETITIONS*
            sum([e.s.iₚ != PMDPs.empty_product_id(mg) for e in trace]))

        a_ids = Dict(zip(vi.action_map, 1:length(vi.action_map)))
        for i = 1:N_TRACE_REPETITIONS # multiple repetitions of MCTS on one trace
            mcts = PMDPs.get_MCTS_planner(mg; params_mcts = params_mcts)
            hrpl = PMDPs.HistoryReplayer(mg, trace)
            mcts_trace = PMDPs.replay(hrpl, mcts, RND(1))
            actions_differ = [~isequal(a1, a2) for (a1, a2) in zip(mcts_trace[:a], vi_trace[:a])]
            if any(actions_differ)
                if verbose
                    println("==========__$(i)__============")
                    println("mc1: $(collect(mcts_trace[:a])))")
                    # println("mc2: $(collect(mcts_trace2[:a]))")
                    println("vi : $(collect(vi_trace[:a]))")
                end
                diff_indeces=findall(actions_differ)
                if verbose
                    print("it:\ta:mc1\ta:vi\tVᵥᵢ(s,a):\t")
                    println(join([[f"{a:.1f}\t" for a in vi.action_map if a<10^8]..., "+inf"]))
                end
                for step = diff_indeces
                    s = vi_trace[step][:s]
                    qₛ = vi.qmat[PMDPs.stateindex(me, s), :]
                    a_mcts = mcts_trace[step][:a]
                    a_vi = vi_trace[step][:a]
                    
                    if verbose
                        println(f"{s}={PMDPs.products(me)[s.iₚ]}")
                        print("$(step):\t$(a_mcts)\t$(a_vi)\t||\t\t")
                        println(join([f"{q:.2f}\t" for q in qₛ]))
                    end
                    q_diff = qₛ[a_ids[a_vi]]-qₛ[a_ids[a_mcts]]
                    if -Inf < q_diff < Inf
                        @assert q_diff > 0
                        push!(qΔ, q_diff)
                        q_diff+=q_diff
                    else
                        n_a_inf_diff+=1
                        push!(qΔ_inf, (qₛ[a_ids[a_vi]], qₛ[a_ids[a_mcts]]))
                    end    
                    n_a_diff += 1
                end
                # display(mcts_trace2)
                # println("\tVS")
                # display(mcts_trace1)
            end
            # mcts = PMDPs.get_MCTS_planner(mg, params_mcts = params_mcts)
            # hrpl = PMDPs.HistoryReplayer(mg, trace)
            # mcts_trace2 = PMDPs.replay(hrpl, mcts, RND(1))
        end
    end

    # trace = PMDPs.simulate_trace(mg, RND(7)) # same trace
    # mcts = PMDPs.get_MCTS_planner(mg; params_mcts = params_mcts)
    # hrpl = PMDPs.HistoryReplayer(mg, trace)
    # mcts_trace = PMDPs.replay(hrpl, mcts, RND(1))
    # display(mcts_trace)

    # sum([e.s.iₚ != PMDPs.empty_product_id(mg) for e in mcts_trace])

    # println(qΔ)
    # print(f"Average difference in Q-values: {sum(qΔ)/(n_a_diff-n_a_inf_diff)} (without {100*n_a_inf_diff/n_a_diff:.2f} % -Inf actions (of all different actions) \n")
    # print(f"from {100*n_a_diff/sum(n_actionable_events):.2f} % of different actions") 
    # print(f" (from {sum(n_actionable_events)} total actionable events)")
    push!(metrics, @ntuple(qΔ, n_a_diff, n_a_inf_diff, n_actionable_events))
end

display(metrics)
# print(qΔ_inf)
# histogram(qΔ, bins=20)
using DataFrames
df = DataFrame(metrics)
sdf = sum.(df)[2:end, :]
x = collect(0:0.5:10.)[2:end]

plot(x, (sdf.qΔ./(sdf.n_a_diff.-sdf.n_a_inf_diff)); label="Q-value difference")
plot!(x, sdf.n_a_inf_diff./sdf.n_a_diff; label="% Inf actions")
plot!(x, sdf.n_a_diff./sdf.n_actionable_events; label="% different actions")


# I should check on specific states. I should also check VI valuation of actions on these states