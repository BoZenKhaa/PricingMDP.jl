function create_continuos_product(start_edge_id::Int64, len::Int64, total_n_edges::Int64)
    product = zeros(Bool, total_n_edges)
    for i in start_edge_id:(start_edge_id+len-1)
        product[i]=true
    end
    return Product{total_n_edges}(product)
end

"""
products = create_continuous_products(edges)
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
Returns nothing if p not in products
"""
function prod2ind(p::Product{Size}, products::Array{Product, 1})
    return indexin([p], products)[1]
end

function ind2prod(i::Int64, products::Array{Product, 1})
    return products[i]
end