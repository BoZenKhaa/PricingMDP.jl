using JET
using PMDPs

function prepare_model()
    nᵣ = 12
    pp_params = Dict(pairs((
                    nᵣ = nᵣ,
                    c = 5,
                    T = Int64(nᵣ*24),
                    demand_scaling_parameter = 2*nᵣ, # keeps the expected demand constant for different numbers of resources, at average 2 per hour-long slot.
                    res_budget_μ = 24.0/nᵣ, # assuming nᵣ is number of timeslots in one day, this means that budget remains 1 per hour.
                    objective = :revenue,
                )))
    pp = PMDPs.single_day_cs_pp(;pp_params...)
    mg = PMDPs.PMDPg(pp)
end

mg = prepare_model()
RNG = Xoshiro(1)
s = rand(RNG, initialstate(mg))

@report_opt PMDPs.sample_request(mg, 3, RNG)

@report_opt PMDPs.sample_customer_budget(mg, s, RNG)