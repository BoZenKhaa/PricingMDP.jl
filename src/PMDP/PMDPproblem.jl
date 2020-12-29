"""
Stuct that defines the pricing MDP problem
"""
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
      @assert are_unique(non_empty_P)
      new{length(non_empty_P), length(c₀)}(non_empty_P,c₀,T,D,B,A,objective)
   end
end

"""Read number of resources and products from type parameters"""
Base.size(pp::PMDPProblem{nₚ, nᵣ}) where {nₚ, nᵣ} = (nₚ, nᵣ)
n_products(pp::PMDPProblem) = size(pp)[1]
n_resources(pp::PMDPProblem) = size(pp)[2]

function problem_selling_horizon(P::AbstractArray{<:Product})::Timestep
   maximum([p.selling_period_end for p in P])
end

selling_period_end(p::PMDPProblem) = p.T

empty_product(p::PMDPProblem) = Product(falses(n_resources(p)), selling_period_end(pp))