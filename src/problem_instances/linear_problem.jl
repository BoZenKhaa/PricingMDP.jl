function linear_pp(;nᵣ::Int64=3,
        kwargs...)
    linear_pp(nᵣ; kwargs...)
end


"""
    For the random demand, the idea is following:
    1) get random intensity for different products between 0 and 1
    2) calcultae resource size of each product.
    3) multiply selling_period*intensity*resources -> expected number of resources to be requested
    4) scale back the intensity so that the actual number fits the total expected resources expected_res
    For the approximation to make sense, at any timestep, the combined arrival of 
    request should be low, i.e. <<0.5
"""
function rand_demand(P::AbstractArray{<:Product}, expected_res::Number, rnd::AbstractRNG) 
    prod_selling_period_end = [p.selling_period_end for p in P]
    prod_resources = [sum(p) for p in P]
    prod_demand_intensity = [rand(rnd) for i in 1:length(P)]
    prod_resource_requests = prod_selling_period_end .* prod_demand_intensity .* prod_resources
    resource_requests = sum(prod_resource_requests)
    prod_probs = prod_demand_intensity .* (expected_res / resource_requests)
    
    # display(prod_probs)
    @assert sum(prod_probs)<0.5 "Product probs $prod_probs are too high with given T=$T and expected resource requests $expected_res"

    D = StaggeredBernoulliScheme(prod_selling_period_end, prod_probs)    
end

"""
For the actions, we want to cover the range of the budgets with some space around
"""
function action_space(P::AbstractArray{<:Product}, res_budget_μ::Number)
    prod_resources = [sum(p) for p in P]
    min_b = minimum(prod_resources)*res_budget_μ
    max_b = maximum(prod_resources)*res_budget_μ 

    min_a = min_b - res_budget_μ
    max_a = max_b + res_budget_μ
    step_a = res_budget_μ/2
    A = collect(min_a:step_a:max_a)
end

function linear_pp(nᵣ::Int64;
        c::Int64=3, 
        T::Int64=10, 
        expected_res::Float64=3., 
        res_budget_μ::Float64=5., 
        objective::Symbol=:revenue)
    
    """
    Initial capacity is the same for every resource
    """
    c₀ = [c for v in 1:nᵣ]

    """
    Resource selling period ends should end one by one at each timestep.
    """
    resource_selling_period_ends = [T for i in 1:nᵣ]
    for i::Int64 in 1:ceil(nᵣ/2)
        resource_selling_period_ends[1:(end-i)].-=1
    end

    """
    Products
    """
    P = PMDPs.create_continuous_linear_products(resource_selling_period_ends)


    """
    Demand
    """
    rnd = Xorshift1024Plus()
    D = rand_demand(P, expected_res, rnd)

    """
    For the budgets, we assume normal distribution per resource.
    """
    B = PMDPs.normal_budgets_per_resource(P, res_budget_μ, res_budget_μ/2)

    """
    Actions
    """
    A = action_space(P, res_budget_μ)

    PMDPs.PMDPProblem(P, c₀, D, B, A, objective)
end
