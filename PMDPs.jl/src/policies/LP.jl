using Gurobi, GLPK
using JuMP
using ..PMDPs
using POMDPSimulators
using POMDPPolicies
using POMDPs
using Suppressor

"""
Get maximal action value that is below the budget b.
"""
function optimal_price(b::Float64, actions::AbstractArray{<:Number})::PMDPs.Action
    best_action = actions[1]
    for a in actions
        if a > b
            return best_action
        else
            best_action = a
        end
    end
    return best_action
end

"""
Calculate hindsight optimal allocation of requests from history recorder simulation history.
Optimization goal can be either "revenue" or "utilization".
Return the optimal allocation and the value of the objective.
Usage: 

mdp_mc = PMDPs.create_PMDP(PMDPg) 
planner = PMDPs.get_MCTS_planner(mdp_mc)

rng = MersenneTwister(123)
hr = HistoryRecorder(max_steps=100, capture_exception=false, rng=rng)
h = simulate(hr, mdp_mc, planner)

MILP_hindsight_pricing(mdp_mc, h)
"""
function MILP_hindsight_pricing(
    mdp::PMDPs.PMDP,
    h::AbstractSimHistory;
    objective::Symbol = :revenue,
    verbose::Bool = false,
    kwargs...,
)

    kwargs = Dict(kwargs)

    # extract request trace from history
    trace = collect(eachstep(h, "s, info"))
    requests = [rec for rec in trace if rec.s.iₚ != PMDPs.empty_product_id(mdp)]

    if length(requests) == 0
        result = (r = 0.0, u = 0.0, alloc = [], action_seq = [], requests = [])
    else
        # get data from trace
        request_resources = [[PMDPs.product(mdp, rec.s)...] for rec in requests]
        request_budgets = [rec.info.b for rec in requests]

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
        E = request_resources
        R = [optimal_price(b, POMDPs.actions(mdp)) for b in request_budgets]

        capacity_constraints = [PMDPs.pp(mdp).c₀...]

        request_ind = 1:length(request_resources)
        capacity_ind = 1:length(capacity_constraints)

        local model
        @suppress_out begin
            if haskey(kwargs, :gurobi) && kwargs[:gurobi]
                if haskey(kwargs, :env)
                    model = Model(() -> Gurobi.Optimizer(kwargs[:env]))
                else
                    model = Model(Gurobi.Optimizer)
                end
                if ~verbose
                    set_optimizer_attribute(model, "OutputFlag", 0)
                end
            else
                model = Model(GLPK.Optimizer)
            end
        end
        # set_optimizer_attribute(model, "Presolve", 0)

        # Variables
        @variable(model, x[request_ind], Bin)


        # Constraints
        @constraint(
            model,
            [j in capacity_ind],
            sum(x[i] * E[i][j] for i in request_ind) <= capacity_constraints[j]
        )

        # Objectives
        if objective == :revenue
            @objective(model, Max, sum(x[i] * R[i] for i in request_ind))
        elseif objective == :utilization
            durations = [sum(rec) for rec in E]
            @objective(model, Max, sum(x[i] * durations[i] for i in request_ind))
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
        utilization =
            sum(sum([x * p for (x, p) in zip(optimal_alloc.data, request_resources)]))

        if verbose
            print(output)
            println("Allocation: ", optimal_alloc.data)
        end

        action_seq = [(alloc == 1.0 ? r : PMDPs.REJECT_ACTION) for (alloc, r) in zip(optimal_alloc.data, R)]

        result = (
            objective_val = obj_val,
            u = utilization,
            alloc = optimal_alloc.data,
            action_seq = action_seq,
            requests = requests,
        )
    end
    return result
end


"""
Returns hindsight based policy for given history.

This is the preffered interface to getting the hindsight actions.
"""
function get_MILP_hindsight_policy(mdp::PMDPs.PMDP, h::AbstractSimHistory; kwargs...)
    (objective_val, u, alloc, action_seq, requests) =
        MILP_hindsight_pricing(mdp, h; objective = PMDPs.objective(mdp), kwargs...)

    timesteps = collect([req[:s].t for req in requests])
    pd = Dict(zip(timesteps, action_seq))

    hp = FunctionPolicy(s -> get(pd, s.t, PMDPs.REJECT_ACTION))
end
