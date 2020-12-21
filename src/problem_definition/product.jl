
"""
Create product that is continuous in the linear graph, i.e. the edges are connected in a line.
"""
function create_continuos_product(start_edge_id::Int64, len::Int64, total_n_edges::Int64)
    product = zeros(Bool, total_n_edges)
    for i in start_edge_id:(start_edge_id+len-1)
        product[i]=true
    end
    return Product{total_n_edges}(product)
end

"""
    create_continuos_products(E)

Create an array of continous products from a linear problem graph given by the array of Edges `E`.

# Examples
```
products = create_continuous_products(edges)
````
"""
function create_continuous_products(edges::Array{Edge})
    # n_products = convert(Int64,(length(edges)+1)length(edges)/2)
    n_edges = length(edges)
    products = Product{n_edges}[]
    push!(products, Product{n_edges}(zeros(Bool, length(edges)))) # Empty product
    for len in 1:length(edges)
        for start in 1:(length(edges)+1-len)
            push!(products, create_continuos_product(start, len, length(edges)))
        end     
    end
    return products
end

"""
Given an array of graph edges and products, return a selling period end for each product. 
"""
function get_product_selling_period_ends(E::Array{Edge}, P::Array{Product{n_edges}}) where n_edges
    selling_period_ends = zeros(Int64, length(P))
    for i in 2:length(P)
        prod = P[i]
        selling_period_ends[i] = minimum([e.selling_period_end for e in E[prod]])
    end
    selling_period_ends[1] = maximum(selling_period_ends[2:end])
    return selling_period_ends
end

