nodes2edges(walk::Array{Int64}) = [Edge(o,d) for (o,d) in zip(walk[1:end-1], walk[2:end])]

walk2prodres(walk::Array{<:Edge}, E::Array{<:Edge}) = sum([map(x-> x==e, E) for e in walk])

function get_prodres(g::SimpleDiGraph, NP::Int64, rnd::AbstractRNG, seed::Int64; max_attempts=10_000)
    walks = Set{Array}()
    i = 1
    while length(walks)<NP && i < max_attempts
        w = self_avoiding_walk(g, rand(rnd, 1:nv(g)),rand(rnd, 1:ne(g)); seed = rand(rnd, 1:(seed+i))) 
        if length(w)>1 push!(walks, w) end # Only walks that have some edges
        i+=1
    end
    collect(walks)
    walks_e = [nodes2edges(w) for w in collect(walks)]
    
    E = collect(edges(g))
    prodress = Array{Bool,1}[walk2prodres(w,E) for w in walks_e]
end


"""
Pricing problem with directed graph product structure, edges are resources
 - seed = seed for generating graph
 - c = initial resource capacity
 - T = same selling period end for all resurces and products
 - expected_res = expected number of consumed resources if all requests were satisfied, used to generate random demand
 - res_budget_μ = mean budget per resource, used to set the customer budgets.
"""

function graph_pp(;NV::Int64=5, NE::Int64=8, NP::Int64=20,
                seed::Int64=2,
                c::Int64 = 5,
                T::Int64 = 20,
                expected_res::Float64 = 20.,
                res_budget_μ::Float64 = 5.)
                
    """
    Graph
    """
    g = SimpleDiGraph(NV, NE, seed=seed)

    # generate connected graph
    attempts = 0
    N_GRAPH_ATTEMPTS = 1000
    while length(connected_components(g))>1 && attempts <= N_GRAPH_ATTEMPTS
        seed = seed*7879+1
        g = SimpleDiGraph(NV, NE, seed=seed)
        attempts+=1
    end
    if attempts >= N_GRAPH_ATTEMPTS
        throw(ErrorException("Connected graph couldnt be found."))
    end

    graph_pp(g, NP; seed = seed, c=c, T=T,
             expected_res=expected_res,
             res_budget_μ=res_budget_μ)
end

function graph_pp(g::SimpleDiGraph, NP::Int64;
                seed::Int64 = 2, 
                c::Int64 = 5,
                T::Int64 = 20,
                expected_res::Float64 = 20.,
                res_budget_μ::Float64 = 5.)
    """
    Capacity
    """
    nᵣ = ne(g)
    c₀ = [c for e in 1:nᵣ]

    """
    Products
    """
    rnd = Xorshift1024Plus(seed)
    P = [PMDPs.Product(prodres, T) for prodres in  get_prodres(g, NP, rnd, seed)]


    D = PMDPs.rand_demand(P, expected_res, rnd)

    B = PMDPs.normal_budgets_per_resource(P, res_budget_μ, res_budget_μ/2)

    A = PMDPs.action_space(P, res_budget_μ)

    (pp = PMDPs.PMDPProblem(P, c₀, D, B, A, :revenue), g = g)
end