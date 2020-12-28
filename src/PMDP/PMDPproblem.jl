"""
Stuct that defines the pricing MDP problem
"""

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


struct PMDPProblem{nₚ, nᵣ}
   P::SVector{nₚ, Product}      # Products array  
   c₀::SVector{nᵣ, Int64}       # Initial capacity of resources
   T::Timestep                  # Number of timesteps
   D::DiscreteCountingProcess   # Demand for each product 
   B::SVector{nₚ, Distribution} # Budget distributions for each product
   A::Array{Action}             # Action set
   objective::Symbol            # objective for optimization

   function PMDPProblem(non_empty_P::AbstractArray{<:Product}, c₀, D, B, A, objective)
      T = problem_selling_horizon(non_empty_P)
      @assert objective in [:revenue, :utilization]
      new{length(non_empty_P), length(c₀)}(non_empty_P,c₀,T,D,B,A,objective)
   end
end

"""Read number of resources and products from type parameters"""
Base.size(pp::PMDPProblem{nₚ, nᵣ}) where {nₚ, nᵣ} = (nₚ, nᵣ)
n_products(pp::PMDPProblem) = size(pp)[1]

function problem_selling_horizon(P::AbstractArray{<:Product})::Timestep
   maximum([p.selling_period_end for p in P])
end

selling_period_end(p::PMDPProblem) = p.T