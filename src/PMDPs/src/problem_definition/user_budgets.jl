"""
Create normal budget distribution for each product with mean given by
the number of resources in the product.
"""
function normal_budgets_per_resource(P::AbstractArray{<:Product}, resource_budget_μ ::Float64, σ::Float64)
    P_sizes = Float64[sum(p) for p in P]
    budget_means = P_sizes .* resource_budget_μ
    [Normal(μ, σ) for μ in budget_means]    
end