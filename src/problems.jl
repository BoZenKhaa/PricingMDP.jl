function create_PMDP(mdp_type::Type;n_edges = 2, c_init = 2,  selling_horizon_end = [10,10], demand = Float64[2,2])  
    edges = create_edges(n_edges, c_init, selling_horizon_end)
    products = create_continuous_products(edges)
    λ = create_λ(demand, products)
    actions = Action[0,15,30,45,1000]
    
    mdp = mdp_type(edges, products, λ, actions)
end