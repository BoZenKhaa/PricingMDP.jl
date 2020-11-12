"""
Tools for generating demand distributions
"""

"""
Requests for each product is generated with Poisson process (fast coin tossing) with intensity λ. 
We consider the time interval of each selling period to be (0,1), so that for each product, expected number of requests is λ.
Because we discretize the time interval (0,1) into 'm' steps, we are approximate the Poisson distribution with Bernouli distribution. 
As such, we have λ~mp where p is the probability of success (success is request arrival in one timestep).

Notable property of Poisson process: mix of poisson processes of different products is a poisson process with multiple possible values.
"""

"""
Create the same demand for all products, sum of which across all products will be λ.

    λ = create_λ(20., products)
"""
function create_λ(demand::Float64, products::Array{Product{n_edges}}) where n_edges
    λ = fill(demand/(length(products)-1), length(products)) 
    λ[1]=0. # product[1] is the empty product
    return λ
end

"""
Create same product demand for each product size. For all products of size len, the expected sum of demands (λ) is demand[len].

    λ = create_λ(Float64[10,3,3,5,4], products)
"""
function create_λ(demand::Array{Float64}, products::Array{Product{n_edges}}) where n_edges
    λ = zeros(Float64, length(products)) 
    sizes = map(sum, products)
    for len in unique(sizes)
        if len==0
            λ[1]=0. # product[1] is the empty product
            continue
        end
        selector = sizes.==len
        λ[selector].= demand[len]/sum(selector)
    end
    return λ
end

