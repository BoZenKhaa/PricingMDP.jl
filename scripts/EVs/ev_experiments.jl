using PMDPs
using PMDPs.LP
using DrWatson
using RandomNumbers.Xorshifts
using MCTS

using POMDPs

RND = Xorshift1024Plus

include(srcdir("MDPPricing.jl"))

pp = PMDPs.linear_pp(2; c = 2, T = 8)
mg = PMDPs.PMDPg(pp)

run(`clear`)
trace2 = PMDPs.simulate_trace(mg, RND(4))
for i = 1:1000
    trace1 = PMDPs.simulate_trace(mg, RND(4))
    if ~isequal(trace1, trace2)
        display(trace1)
        display(trace2)
        print("======================")
    end
    trace2 = PMDPs.simulate_trace(mg, RND(4))
end


params_mcts = (
    max_iter = 100,
    max_depth = 10,
    c = 2,
    T = 8,
    discount = 0.9,
    rnd = RND(4),
    verbose = true,
)


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

params_mcts = Dict(
    pairs((
        solver = MCTSSolver,
        depth = 50,
        exploration_constant = 40.0,
        enable_state_pw = false,
        keep_tree = true,
        show_progress = false,
        rng = RND(1),
    )),
)



deepcopy(params_mcts)

# dpw_solver_params = (;depth=50, 
#     exploration_constant=40.0, max_time=1.,
#     enable_state_pw = false, 
#     keep_tree=true, show_progress=false, rng=Xorshift128Plus())

trace = PMDPs.simulate_trace(mg, RND(5))

mcts = PMDPs.get_MCTS_planner(mg)
# PMDPs.eval_policy(mg, [trace], @ntuple(mcts), MersenneTwister(1))
hrpl = PMDPs.HistoryReplayer(mg, trace)
mcts_trace2 = PMDPs.replay(hrpl, mcts, RND(1))
for i = 1:10
    mcts = PMDPs.get_MCTS_planner(mg; params_mcts = Dict(pairs((rng = RND(1),))))
    hrpl = PMDPs.HistoryReplayer(mg, trace)
    mcts_trace1 = PMDPs.replay(hrpl, mcts, RND(1))
    if ~isequal(mcts_trace1, mcts_trace2)
        display(mcts_trace1)
        display(mcts_trace2)
        print("======================")
    end
    mcts = PMDPs.get_MCTS_planner(mg)
    hrpl = PMDPs.HistoryReplayer(mg, trace)
    mcts_trace2 = PMDPs.replay(hrpl, mcts, RND(1))
end
