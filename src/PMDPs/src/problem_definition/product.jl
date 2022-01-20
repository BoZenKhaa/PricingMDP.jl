
"""
Create product that is continuous in the linear graph, i.e. the edges are connected in a line.
"""
function create_continuous_linear_product(
    start_res_id::Int64,
    len::Int64,
    n_res::Int64,
    resource_selling_period_ends::Array{Int64},
)
    product = zeros(Bool, n_res)
    spe = typemax(Int64)
    for i = start_res_id:(start_res_id+len-1)
        product[i] = true
        spe = minimum([spe, resource_selling_period_ends[i]])
    end
    return Product(product, spe)
end

"""
    create_continuos_products(resource_selling_period_ends)

Create an array of continous products from a linear problem graph given by the array of resources

# Examples
```
products = create_continuous_products(resources)
````
"""
function create_continuous_linear_products(resource_selling_period_ends::Array{Int64})
    n_res = length(resource_selling_period_ends)
    products = Product[]
    for len = 1:n_res
        for start = 1:(n_res+1-len)
            push!(
                products,
                create_continuous_linear_product(
                    start,
                    len,
                    n_res,
                    resource_selling_period_ends,
                ),
            )
        end
    end
    return products
end
