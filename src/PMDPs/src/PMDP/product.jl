# const Product{n_edges} = SVector{n_edges,Bool}
struct Product <: AbstractVector{Bool}
    res::Vector{Bool}
    selling_period_end::Timestep
end

selling_period_end(p::Product) = p.selling_period_end
resources(p::Product) = p.res

# Vector interface for product
Base.size(p::Product) = size(p.res)
function Base.getindex(p::Product, i::Int)
    p.res[i]
end

function are_unique(products::AbstractArray{<:AbstractArray})
    length(Set(products)) == length(products)
end

