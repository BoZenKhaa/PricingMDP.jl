"""
Tools for generating problem graphs
"""


"""
    create_edges(n_edges, c, selling_horizon_ends)

Create `n_edges` pricing problem edges for linear pricing problem with given capacity `c` and selling periods ending at `selling_period_ends`.

# Example
```
julia> edges = create_edges(5, 2, [50,60,70,80,90])
5-element Array{PMDPs.Edge,1}:
 PMDPs.Edge(1, 2, 50)
 PMDPs.Edge(2, 2, 60)
 PMDPs.Edge(3, 2, 70)
 PMDPs.Edge(4, 2, 80)
 PMDPs.Edge(5, 2, 90)
```
"""
function create_linear_graph(n_edges::Int64, c::Int64, selling_horizon_ends::Array{Timestep})
    [Edge(i, c, selling_horizon_ends[i]) for i in 1:n_edges]
end