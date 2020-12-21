"""
Stuct that defines the pricing MDP problem
"""

"""
Types used in the PMDP
"""
const Action = Float64
const Timestep = Int64

# const Product{n_edges} = SVector{n_edges,Bool}
struct Product{n_res} <: StaticArray{Tuple{n_res}, Bool, 1}
    res::SVector{n_res, Bool}
    selling_period_end::Timestep
end

function Product(res::Array{Bool}, selling_period_end::Timestep)
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
   P::SVector{nₚ, Product}
   C₀::SVector{nᵣ, Int64}
   T::Timestep
   D::SVector{nₚ, Float64}
   B::SVector{nₚ, Distribution}
   A::Array{Action}
   objective::Symbol

   function PMDPProblem(non_empty_P::AbstractArray{<:Product}, C₀, D, B, A, objective)
      T = problem_selling_horizon(non_empty_P)
      @assert objective in [:revenue, :utilization]
      new{length(non_empty_P), length(C₀)}(non_empty_P,C₀,T,D,B,A,objective)
   end
end

function problem_selling_horizon(P::AbstractArray{<:Product})::Timestep
   maximum([p.selling_period_end for p in P])
end

selling_period_end(p::PMDPProblem) = p.T