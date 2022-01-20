function linear_pp(; nᵣ::Int64 = 3, kwargs...)
    linear_pp(nᵣ; kwargs...)
end


"""
Demand intensity modelled after the CS usecase. Has two component distributions that are assumed to be independent.:
    1. charging start time - e.g. following normal distribution during the day, 
    possibly, it could be also normal distribution with two peaks
    2. charging duration - e.g. exponential distribution

The two components are considered to be independent. The output bivariate distribution 
is discretized on the timestep and timeslot discretization and narroed down only to the products under consideration,
then normalized.

Example:
start_time = truncated(Normal(nᵣ/2, nᵣ/8), 0, nᵣ)
duration = truncated(Exponential(nᵣ/8), 0, nᵣ)

demand_intensity_indpendent_start_time_and_duration(start_time, duration)
"""
function demand_intensity_indpendent_start_time_and_duration(start_time::Distribution, duration::Distribution, nᵣ::Integer, P::AbstractArray{<:Product})
    # using StatPlots
    # plot(start_time)
    # plot(duration)

    # product_demand_intensity = Product([start_time, duration])
    # cdf(start_time, 0)

    start_timeslot_probs = [cdf(start_time, ts)-cdf(start_time, ts-1) for ts = 1:nᵣ]
    # sum(start_timeslot_probs)

    duration_timeslot_probs = [cdf(duration, ts)-cdf(duration, ts-1) for ts = 1:nᵣ]
    # sum(duration_timeslot_probs)

    full_product_demand_intensity = start_timeslot_probs*duration_timeslot_probs'
    # heatmap(start_timeslot_probs*duration_timeslot_probs')

    prod_demand_intensity = [full_product_demand_intensity[sum(p), findfirst(p)] for p in P]
    # the matrix has more possible products than we allow in the mdp, this checks whether the error from that is small
    @assert sum(prod_demand_intensity)>0.95
    # and then normalize
    normalized_prod_demand_intensity = prod_demand_intensity ./ sum(prod_demand_intensity)
end

"""
Random demand intensity for every product.
"""
function random_product_demand_intensity(P::AbstractArray{<:Product}, rnd::AbstractRNG)
    prod_demand_intensity = [rand(rnd) for i = 1:length(P)]
    normalized_prod_demand_intensity = prod_demand_intensity ./ sum(prod_demand_intensity)
end


"""
    For the random demand, the idea is following:
    1) get demand intensity for different products as argument (not necessarly normalized)
    2) calculate resource size of each product.
    3) multiply selling_period*intensity*resources -> expected number of resources to be requested
    4) scale back the intensity so that the actual number fits the total expected resources expected_res
    For the approximation to make sense, at any timestep, the combined arrival of 
    request should be low, i.e. <<0.5

    This use of StaggeredBernoulliScheme means that the "lead time", the time between the arrival of request 
    and the end of selling period, has a uniform distribution for each product? 

    args:
        P: array of products
        expected_res: demand scaling parameter, total expected number of resources to be requested in the pricing problem
        relative_prod_demand_intensity: normalized vector of product intensities, a cathegorical distribution (pdf) over products
"""
function demand(P::AbstractArray{<:Product}, expected_res::Number, relative_prod_demand_intensity::AbstractVector{<:Number})
    @assert sum(relative_prod_demand_intensity) ≈ 1.0
    
    prod_selling_period_end = [p.selling_period_end for p in P]
    prod_resources = [sum(p) for p in P]

    scaled_demand_intensity = relative_prod_demand_intensity*expected_res

    prod_probs = scaled_demand_intensity./(prod_selling_period_end.*prod_resources)

    # display(prod_probs)
    @assert sum(prod_probs) < 0.5 "Product probs $prod_probs are too high with given T=$(maximum(prod_selling_period_end)) and expected resource requests $expected_res"

    D = StaggeredBernoulliScheme(prod_selling_period_end, prod_probs)
end

"""
For the actions, we want to cover the range of the budgets with some space around
"""
function action_space(P::AbstractArray{<:Product}, res_budget_μ::Number)
    prod_resources = [sum(p) for p in P]
    min_b = minimum(prod_resources) * res_budget_μ
    max_b = maximum(prod_resources) * res_budget_μ

    min_a = min_b - res_budget_μ
    max_a = max_b + res_budget_μ
    step_a = res_budget_μ / 2
    A = collect(min_a:step_a:max_a)
end

function linear_pp(
    nᵣ::Int64;
    c::Int64 = 3,
    T::Int64 = 10,
    expected_res::Float64 = 3.0,
    res_budget_μ::Float64 = 5.0,
    objective::Symbol = :revenue,
    rnd=Xorshift1024Plus(1)
)

    """
    Initial capacity is the same for every resource
    """
    c₀ = [c for v = 1:nᵣ]

    """
    Resource selling period ends should end one by one at each timestep.
    """
    resource_selling_period_ends = [T for i = 1:nᵣ]
    for i::Int64 = 1:ceil(nᵣ / 2)
        resource_selling_period_ends[1:(end-i)] .-= 1
    end

    """
    Products
    """
    P = PMDPs.create_continuous_linear_products(resource_selling_period_ends)


    """
    Demand
    """
    product_demand_intensity = random_demand_intensity(P, rnd)
    D = demand(P, expected_res, product_demand_intensity)

    """
    For the budgets, we assume normal distribution per resource.
    """
    B = PMDPs.normal_budgets_per_resource(P, res_budget_μ, res_budget_μ / 2)

    """
    Actions
    """
    A = action_space(P, res_budget_μ)

    PMDPs.PMDPProblem(P, c₀, D, B, A, objective)
end

"""
In this case, resources are timeslots.
Both timeslots and timesteps start at 00:00 and end at 23:59.
"""
function single_day_cs_pp(
    start_times::Distribution,
    charging_durations::Distribution;
    nᵣ::Integer=12, # number of timeslots per day
    c::Integer = 3,   # charging capacity of every timeslot
    T::Integer = 24,  # number of timesteps in the day
    expected_res::Number = 3.0,
    res_budget_μ::Number = 5.0,
    objective::Symbol = :revenue,
)
    """
    Initial capacity is the same for every resource
    """
    c₀ = [c for v = 1:nᵣ]

    """
    Resource selling period ends when timestep reaches the start of the timeslot.

    Assume timeslots comprise of integer number of timesteps.
    """
    @assert T%nᵣ == 0 "T, the number of timesteps, must be a multiple of nᵣ, the number of charging timeslots"
    timesteps_per_timeslot = T ÷ nᵣ # integer division
    resource_selling_period_ends =[ts * timesteps_per_timeslot for ts = 1:nᵣ]

    """
    Products - only continous charging sessions
    """
    P = PMDPs.create_continuous_linear_products(resource_selling_period_ends)

    """
    Demand
    """
    product_demand_intensity =  PMDPs.demand_intensity_indpendent_start_time_and_duration(start_times, charging_durations, nᵣ, P)
    D = PMDPs.demand(P, expected_res, product_demand_intensity)

    """
    For the budgets, we assume normal distribution per resource.

    I could also assume smaller budget per resource for larger products, 
    but lets forget about that for now.
    """
    B = PMDPs.normal_budgets_per_resource(P, res_budget_μ, res_budget_μ / 2)

    """
    Actions
    """
    A = action_space(P, res_budget_μ)

    PMDPs.PMDPProblem(P, c₀, D, B, A, objective)
end


"""
This is an artificial example with parametrically specified start times and charging durations.
"""
function single_day_cs_pp(;
    nᵣ=12, # number of timeslots per day
    c = 3,   # charging capacity of every timeslot
    T = 24,  # number of timesteps in the day
    expected_res = 3.0,
    res_budget_μ = 5.0,
    objective = :revenue,
)
    start_times = truncated(Normal(nᵣ/2, nᵣ/8), 0, nᵣ)
    charging_durations = truncated(Exponential(nᵣ/8), 0, nᵣ)
    single_day_cs_pp(start_times, charging_durations; nᵣ, c, T, expected_res, res_budget_μ, objective)
end