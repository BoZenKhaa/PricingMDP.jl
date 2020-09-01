"""
edges = create_edges(n_edges, 5, [50,60,70,80,90])
"""
function create_edges(n_edges::Int64, c::Int64, selling_horizon_ends::Array{Timestep})
    [Edge(i, c, selling_horizon_ends[i]) for i in 1:n_edges]
end

function get_selling_period_ends(E::Array{Edge}, P::Array{Product{n_edges}}) where n_edges
    selling_period_ends = zeros(Int64, length(P))
    for i in 2:length(P)
        prod = P[i]
        selling_period_ends[i] = minimum([e.selling_period_end for e in E[prod]])
    end
    selling_period_ends[1] = maximum(selling_period_ends[2:end])
    return selling_period_ends
end

"""
Get product arrival probablities from homogenous Pois. proc. intensities λ, 
while considering the product selling periods.

Given λ, the expected number of request in period (0,1), 
the probability of request arrivel in given timestep is given by λ~mp where m is the number of timesteps in period (0,1).
"""
function calculate_product_request_probs(t::Timestep,  λ::Array{Float64}, selling_period_ends::Array{Timestep})
    product_request_probs = Array{Float64, 1}(undef, length(λ))
    for i in 2:length(selling_period_ends)
        if t>selling_period_ends[i]
            product_request_probs[i]=0
        else
            product_request_probs[i]=λ[i]/selling_period_ends[i]
        end
    end
    product_request_probs[1] = 1-sum(product_request_probs[2:end])
    @assert 0. <= product_request_probs[1] <= 1. "The product request probability has sum > 1, finer time discretization needed."
    return product_request_probs
end