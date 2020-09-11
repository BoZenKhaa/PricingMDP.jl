function create_PMDP(mdp_type::Type;n_edges = 2, 
        c_init = 2,  selling_horizon_end = [10,10], 
        demand = Float64[2,2], actions =  Action[0,15,30,45,1000])  
    edges = create_edges(n_edges, c_init, selling_horizon_end)
    products = create_continuous_products(edges)
    λ = create_λ(demand, products)
    
    mdp = mdp_type(edges, products, λ, actions)
end

create_PMDPe2(mdp_type::Type) = create_PMDP(mdp_type)
create_PMDPe3(mdp_type::Type) = create_PMDP(mdp_type; n_edges = 3,
    c_init = 2, selling_horizon_end = [50,60,70], 
    demand = Float64[5,3,1], actions = Action[0,15,30,45,60,75,1000])
create_PMDPe5(mdp_type::Type) = create_PMDP(mdp_type;
    n_edges = 5, c_init = 4, selling_horizon_end = [50,60,70,80,90], 
    demand = Float64[10,3,3,5,4], actions = Action[0:5:100;])
