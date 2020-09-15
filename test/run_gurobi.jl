using PricingMDP
using Test
using POMDPSimulators

using StaticArrays
using POMDPs
using MCTS, DiscreteValueIteration
using StatsBase
using Plots
using POMDPSimulators
using D3Trees
using POMDPPolicies
using POMDPLinter
using Random
using DataFrames
using POMDPSimulators


mdp_vi = PricingMDP.create_PMDP(PMDPe)
mdp_mc = PricingMDP.create_PMDP(PMDPg) 

policy = PricingMDP.get_VI_policy(mdp_vi)
planner = PricingMDP.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(1234)

s0 = rand(rng, initialstate(mdp_mc))

# function run_sim(mdp::PMDP, policy::Policy; rng_seed=1234)
#     rng = MersenneTwister(rng_seed)
#     hr = HistoryRecorder(max_steps=100, capture_exception=true, rng=rng)
#     h = simulate(hr, mdp, policy)
#     collect(eachstep(h, "s, a, r, user_budget"))
#     # sum(h[:r])
# end

rng = MersenneTwister(12)
hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
h = simulate(hr, mdp_mc, planner)
collect(eachstep(h, "s, a, r, info"))

# @show run_sim(mdp_mc, policy; rng_seed = 1235)

# ch = run_sim(mdp_mc, planner; rng_seed = 1236)
# @show ch
# any(ch[end][:s].c .< 0)


# for i in 1:10000
#     ch = run_sim(mdp_vi, planner; rng_seed = i)
#     print(i, " ")
#     any(ch[end][:s].c .< 0) ? break : continue
# end
# action(planner, s0)

      # get data from trace
      request_edges = trace_fs.edge_id
      request_budgets = trace_fs.user_budget

      # prepare data
      """ E: Matrix that has requests as rows and columns as capacity edges
          R: List of maximum prices that users will accept
      e.g. matrix for 4 request in problem with 3 edges and capacity 3:
      E = [[1,1,0], 
           [1,0,0],
           [1,1,1], 
           [0,0,1]]
      R = [20, 10, 30, 10]
      capacity_constraints = [3,3,3]
      """
      E = [graph.edgeid_to_capvec(edge_id) for edge_id in request_edges]
      R = [optimal_price(budget, graph.price_range) for budget in request_budgets]  #

      capacity_constraints = [graph.capacity for i in graph.get_edges_of_length(1)]

      request_ind = range(len(trace_fs))  # [0,1,2,3]
      capacity_ind = range(len(capacity_constraints))  # [0,1,2]

      # model
      m = gu.Model("milp")
      m.setParam('OutputFlag', verbose)

      # Variables
      x = m.addVars(request_ind, vtype=gu.GRB.BINARY, name='x')

      # Objective
      if graph.optimization_goal == 'revenue':
          budget_dict = dict(zip(request_ind, R))
          obj = x.prod(budget_dict)
      elif graph.optimization_goal == 'utilization':
          durations = [sum(r) for r in E]
          budget_dict = dict(zip(request_ind, durations))
          obj = x.prod(budget_dict)
      else:
          raise ValueError('Unknown optimization goal: {}'.format(graph.optimization_goal))
      m.setObjective(obj, gu.GRB.MAXIMIZE)

      # Constraints
      for j in capacity_ind:
          e = gu.tupledict([(i, E[i][j]) for i in request_ind])
          cstr = x.prod(e) <= capacity_constraints[j]
          m.addConstr(cstr, name='c_{}'.format(j))

      # Optimize
      m.optimize()

      # Report results
      optim_alloc = []
      for v in m.getVars():
          if verbose:
              print('{} {}'.format(v.varName, int(v.x)))
          optim_alloc.append(int(v.x))

      if verbose:
          print('Objective value: {}'.format(m.objVal))

      return m.objVal, optim_alloc