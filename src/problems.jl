function create_PMDP(mdp_type::Type;
        n_edges = 2, 
        c_init = 2,  
        selling_horizon_end = [10,10], 
        demand = Float64[2,2], 
        user_budgets = BudgetPerUnit(Distributions.Uniform(5,30)), 
        actions =  Action[15,30,45])  
        
    edges = create_edges(n_edges, c_init, selling_horizon_end)
    products = create_continuous_products(edges)
    λ = create_λ(demand, products)
    
    all_actions = [0, collect(actions)..., 10000]
    mdp = mdp_type(edges, products, λ, user_budgets, all_actions)
end

create_PMDPe2(mdp_type::Type) = create_PMDP(mdp_type)
create_PMDPe3(mdp_type::Type) = create_PMDP(mdp_type; n_edges = 3,
    c_init = 2, selling_horizon_end = [50,60,70], 
    demand = Float64[5,3,1], actions = Action[15,30,45,60,75])
create_PMDPe5(mdp_type::Type) = create_PMDP(mdp_type;
    n_edges = 5, c_init = 4, selling_horizon_end = [50,60,70,80,90], 
    demand = Float64[10,3,3,5,4], actions = Action[5:5:100;])

create_PMDPe10(mdp_type::Type) = create_PMDP(mdp_type;
n_edges = 10, c_init = 30, selling_horizon_end = [910,920,930,940,950,960,970,980,990,1000], 
demand = Float64[1,1,1,1,1,1,1,1,1,20], actions = Action[5:5:100;])    