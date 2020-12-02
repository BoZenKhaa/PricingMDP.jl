using Gurobi
using JuMP
using PricingMDP
using POMDPSimulators
using POMDPPolicies
using Suppressor

"""
Get maximal action value that is below the budget b.
"""
function optimal_price(b::Float64, actions::Array{Action})::Action
    best_action = actions[1]
    for a in actions
        if a > b
            return best_action
        else
            best_action=a
        end
    end
    return best_action
end

"""
Calculate hindsight optimal allocation of requests from history recorder simulation history.
Optimization goal can be either "revenue" or "utilization".
Return the optimal allocation and the value of the objective.
Usage: 

mdp_mc = PricingMDP.create_PMDP(PMDPg) 
planner = PricingMDP.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(123)
hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
h = simulate(hr, mdp_mc, planner)

MILP_hindsight_pricing(mdp_mc, h)
"""
function MILP_hindsight_pricing(mdp::PMDP, h::AbstractSimHistory; objective=:revenue, verbose=false)

    # extract request trace from history
    trace = collect(eachstep(h, "s, info"))
    requests = [rec for rec in trace if rec.s.p!=PricingMDP.empty_product(mdp)]
    if length(requests)==0
        return (r = 0., u = 0., alloc = [])
    end

    # get data from trace
    request_edges = [[rec.s.p...] for rec in requests]
    request_budgets = [rec.info for rec in requests]

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
    E = request_edges
    R = [optimal_price(b, mdp.actions) for b in request_budgets]

    capacity_constraints = [e.c_init for e in mdp.E]

    request_ind = 1:length(request_edges)
    capacity_ind = 1:length(capacity_constraints)

    local model
    @suppress_out begin
        model = Model(Gurobi.Optimizer)
    end
    # set_optimizer_attribute(model, "Presolve", 0)
    if ~verbose  set_optimizer_attribute(model, "OutputFlag", 0) end

    # Variables
    @variable(model, x[request_ind], Bin)


    # Constraints
    @constraint(model, [j in capacity_ind], 
            sum(x[i]*E[i][j] for i in request_ind) <= capacity_constraints[j])

    # Objectives
    if objective == :revenue
        @objective(model, Max, 
            sum(x[i]*R[i] for i in request_ind))
    elseif  objective == :utilization
        durations = [sum(rec) for rec in E]
        @objective(model, Max, 
            sum(x[i]*durations[i] for i in request_ind))
    else
        error("unknown MILP optimization goal $optimization_goal")
    end


    # Optimize and capture std_out
    output = @capture_out optimize!(model)

    # Report results
    status = termination_status(model)
    obj_val = objective_value(model)
    optimal_alloc = JuMP.value.(x)

    # Calculate utilization
    utilization = sum(sum([x*p for (x,p) in zip(optimal_alloc.data, request_edges)]))

    if verbose 
        print(output) 
        println("Allocation: ", optimal_alloc.data)
    end

    return (r = obj_val, u = utilization, alloc = optimal_alloc.data, 
            action_seq = optimal_alloc.data.*R)
    
end


"""
Returns hindsight based policy for given history.

This is the preffered interface to getting the hindsight actions.
"""
function get_MILP_hindsight_policy(mdp::PMDP, h::AbstractSimHistory)
    r, u, alloc, action_seq = PricingMDP.LP.MILP_hindsight_pricing(mdp, h; objective=PricingMDP.objective(mdp))
    
    timesteps = collect([s.t for s in h[:s]])
    acts = prepend!(action_seq,0)
    pd = Dict(zip(timesteps, acts))

    hp = FunctionPolicy(s -> pd[s.t])
end