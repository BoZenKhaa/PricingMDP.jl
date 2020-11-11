"""
Tools for generating problem graphs
"""


"""
    create_edges(n_edges, c, selling_horizon_ends)

Create `n_edges` pricing problem edges for linear pricing problem with given capacity `c` and selling periods ending at `selling_period_ends`.

# Example
```
julia> edges = create_edges(5, 2, [50,60,70,80,90])
5-element Array{PricingMDP.Edge,1}:
 PricingMDP.Edge(1, 2, 50)
 PricingMDP.Edge(2, 2, 60)
 PricingMDP.Edge(3, 2, 70)
 PricingMDP.Edge(4, 2, 80)
 PricingMDP.Edge(5, 2, 90)
```
"""
function create_edges(n_edges::Int64, c::Int64, selling_horizon_ends::Array{Timestep})
    [Edge(i, c, selling_horizon_ends[i]) for i in 1:n_edges]
end