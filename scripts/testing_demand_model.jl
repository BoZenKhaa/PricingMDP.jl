using Revise

using PMDPs
using PMDPs.CountingProcesses
using Random
using DrWatson
using ProgressMeter
using Logging
using Distributions

include(srcdir("MDPPricing.jl"))
using .MDPPricing




OBJECTIVE = PMDPs.REVENUE
nᵣ = 12 # number of resources
demand_scaling_parameter = nᵣ

pp_params = Dict(pairs((
    nᵣ = nᵣ,
    c = 1,
    T = Int64(demand_scaling_parameter*4),
    demand_scaling_parameter = demand_scaling_parameter, # keeps the expected demand constant for different numbers of resources
    res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per HOUR of charging.
    objective = OBJECTIVE,
)))

pp = PMDPs.single_day_cs_pp(;pp_params...)

[sum(p) for p in pp.P]


negative_outcome = PMDPs.empty_product_id(pp)
D = pp.D
T = pp.T
P = pp.P

sum(P[10])

function test_demand(D, T, P, negative_outcome, n_repeats = 1000)
    rng = MersenneTwister(1234)
    counts = []
    lengths = Dict()
    for i in 1:n_repeats
        n_req = 0
        for i in 1:T
            outcome = sample_any_outcome(rng, D, i)
            if outcome!=negative_outcome
                n_req += 1
                lengths[sum(P[outcome])] = get(lengths, sum(P[outcome]), 0) + 1
            end
        end
        push!(counts, n_req)
        # println(n_req)
    end
    # mean
    for (k, v) in lengths
        lengths[k] = v/n_repeats
    end

    sum(counts)/length(counts), lengths
end

test_demand(D, T, P, negative_outcome), demand_scaling_parameter, T

"""
Detailed testing
"""

T = Int64(demand_scaling_parameter*4)


"""
Products - only continous charging sessions
"""
P = PMDPs.create_continuous_linear_products(nᵣ)


function prep_demand(T, nᵣ, demand_scaling_parameter, P)
    start_times = truncated(Normal(nᵣ/2, nᵣ/8), 0, nᵣ)
    charging_durations = truncated(Exponential(nᵣ/8), 0, nᵣ)
    
    # @assert T%nᵣ == 0 "T, the number of timesteps, must be a multiple of nᵣ, the number of charging timeslots"
    timesteps_per_timeslot = T ÷ nᵣ # integer division

    resource_selling_period_ends =[ts * timesteps_per_timeslot for ts = 1:nᵣ]
    # resource_selling_period_ends =[ts * timesteps_per_timeslot for ts = 0:(nᵣ-1)]
    product_selling_period_ends = PMDPs.resource2product_selling_period_ends(P, resource_selling_period_ends)

    # product_selling_period_ends = [T for p in P]

    relative_prod_demand_intensity =  PMDPs.demand_intensity_indpendent_start_time_and_duration(start_times, charging_durations, nᵣ, P)

    # D = PMDPs.demand(P, product_selling_period_ends, demand_scaling_parameter, product_demand_intensity)
    scaled_demand_intensity = relative_prod_demand_intensity .* demand_scaling_parameter
    # scaled_demand_intensity

    prod_probs = scaled_demand_intensity ./ product_selling_period_ends

    @assert sum(prod_probs) < 0.7 "Product probs $prod_probs are too high with given T=$(maximum(product_selling_period_ends)) and demand scaling parameter $demand_scaling_parameter"

    # D = StaggeredBernoulliScheme(product_selling_period_ends, prod_probs)

    D = NonHomogenousBernoulliScheme(product_selling_period_ends, prod_probs)
end

for nᵣ in [3, 4, 6, 8, 10, 12, 16, 20, 24, 30]
    demand_scaling_parameter = 6*nᵣ
    P = PMDPs.create_continuous_linear_products(nᵣ)
    T = Int64(demand_scaling_parameter*4)
    D = prep_demand(T, nᵣ, demand_scaling_parameter, P)
    negative_outcome = length(P)+1
    measured_n_req, length_counts = test_demand(D, T, P, negative_outcome)
    println( "Measured: $measured_n_req, expected: $(demand_scaling_parameter)")
    println(length_counts)
end

D = prep_demand(T, nᵣ, demand_scaling_parameter, P)
measured_n_req, length_counts = test_demand(D, T, P, negative_outcome)
println( "Measured: $measured_n_req, expected: $(demand_scaling_parameter)")
println(length_counts)
