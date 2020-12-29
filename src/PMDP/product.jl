# const Product{n_edges} = SVector{n_edges,Bool}
struct Product{n_res} <: StaticArray{Tuple{n_res}, Bool, 1}
    res::SVector{n_res, Bool}
    selling_period_end::Timestep
end

function Product(res::AbstractArray{<:Bool}, selling_period_end::Timestep)
    Product(SA[res...],selling_period_end)
end

selling_period_end(p::Product) = p.selling_period_end
resources(p::Product) = p.res

# Vector interface for product
@inline Tuple(p::Product) = p.res.data
StaticArrays.@propagate_inbounds function Base.getindex(p::Product, i::Int)
    p.res.data[i]
end

function are_unique(products::AbstractArray{<:AbstractArray})
    length(Set(products))==length(products)
end