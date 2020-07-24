"""
    pwl(10, slope_start=5., slope_end=30.)

PieceWise Linear "step" function with slope in the middle, like so:
  1-|-----\\
    |      \\
    |       \\
  0-|-----|--\\------
    0  start end

TODO: Handle better configuration of user model in problem, now its hardcoded here.
"""
function pwl(x::Number;
            slope_start::Float64=5.,
            slope_end::Float64=30.)
    if x<slope_start
        return 1.
    elseif x>slope_end
        return 0.
    else
        return (x-slope_end)/(slope_start-slope_end)
    end
end

const n_edges = 5
# const products = [SA[0,0,0],SA[1,0,0], SA[0,1,0], SA[0,0,1], SA[1,1,0], SA[0,1,1], SA[1,1,1]]

struct Edge
    id::Int64
    c::Int64                    # capacity
    selling_period_end::Int64  
end

Product = SVector{n_edges,Bool}
Action = Float64
Timestep = Int64


"""
edges = create_edges(n_edges, 5, [50,60,70,80,90])
"""
function create_edges(n_edges::Int64, c::Int64, selling_horizon_ends::Array{Int64})
    edges = Array{Edge}(undef, n_edges)
    for i in 1:n_edges
        edges[i] = Edge(i, c, selling_horizon_ends[i])
    end
    return edges
end

function create_continuos_product(start_edge_id::Int64, len::Int64, total_n_edges::Int64)
    product = zeros(Bool, total_n_edges)
    for i in start_edge_id:(start_edge_id+len-1)
        product[i]=true
    end
    return Product(product)
end


"""
products = create_continuous_products(edges)
"""
function create_continuous_products(edges::Array{Edge})
    # n_products = convert(Int64,(length(edges)+1)length(edges)/2)
    products = Product[]
    push!(products, Product(zeros(Bool, length(edges)))) # Empty product
    for len in 1:length(edges)
        for start in 1:(length(edges)+1-len)
            push!(products, create_continuos_product(start, len, length(edges)))
        end     
    end
    return products
end

struct State
    c::SVector{n_edges,Int64}   # Capacity vector
    t::Timestep                # Timestep
    p::Product    # Requested product
end

function show(io::IO, s::State)
    println(io, "t:$(s.t)_c:$(s.c)_p:$(s.p)")
end


"""
Returns nothing if p not in products
"""
function prod2ind(p::Product, products::Array{Product})
    return indexin([p], products)[1]
end

function ind2prod(i::Int64, products::Array{Product})
    return products[i]
end

function get_selling_period_end(E::Array{Edge}, P::Array{Product})
    selling_period_end = zeros(Int64, length(P))
    for i in 2:length(P)
        prod = P[i]
        selling_period_end[i] = minimum([e.selling_period_end for e in E[prod]])
    end
    selling_period_end[1] = maximum(selling_period_end[2:end])
    return selling_period_end
end

"""
Given λ, the expected number of request in period (0,1), 
the probability of request arrivel in given timestep is given by λ~mp where m is the number of timesteps in period (0,1).
"""
function set_product_request_p!(product_request_p::Array{Float64}, t::Int64,  λ::Array{Float64}, selling_period_end::Array{Int64})
    for i in 2:length(selling_period_end)
        if t>selling_period_end[i]
            product_request_p[i]=0
        else
            product_request_p[i]=λ[i]/selling_period_end[i]
        end
    end
    product_request_p[1] = 1-sum(product_request_p[2:end])
    @assert 0. <= product_request_p[1] <= 1. "The product request probability has sum > 1, finer time discretization needed."
end


"""
m = PMDPv2(edges, products, λ)
"""
struct PMDPv2 <: MDP{State, Float64}
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product}
    λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    selling_period_end::Array{Int64} # Selling period end for each product
    product_request_p::Array{Float64} # probability of request arriving in timestep (homogenous Poisson process)
    
    function PMDPv2(E, P, λ)
        selling_period_end = get_selling_period_end(E, P)
        T = selling_period_end[1]
        product_request_p = zeros(Float64, length(P))
        set_product_request_p!(product_request_p, 0, λ, selling_period_end)
        return new(T,E,P,λ, selling_period_end, product_request_p)
    end
end

"""
Requests for each product is generated poisson process (fast coin tossing) with intensity λ. 
We consider the time interval of each selling period to be (0,1), so that for each product, expected number of requests is λ.
Because we discretize the time interval (0,1) into 'm' steps, we are approximate the Poisson distribution with Bernouli distribution. 
As such, we have λ~mp where p is the probability of success (success is request arrival in one timestep).

Notable property of Poisson process: mix of poisson processes of different products is a poisson process with multiple possible values.
"""

"""
Create the same demand for all products, sum of which across all products will be λ.

    λ = create_λ(20., products)
"""
function create_λ(demand::Float64, products::Array{Product})
    λ = fill(demand/(length(products)-1), length(products)) 
    λ[1]=0. # product[1] is the empty product
    return λ
end

"""
Create same product demand for each product size. For all products of size len, the expected sum of demands is λ[len].

    λ = create_λ(Float64[10,3,3,5,4], products)
"""
function create_λ(demand::Array{Float64}, products::Array{Product})
    λ = zeros(Float64, length(products)) 
    sizes = map(sum, products)
    for len in unique(sizes)
        if len==0
            λ[1]=0. # product[1] is the empty product
            continue
        end
        selector = sizes.==len
        λ[selector].= demand[len]/sum(selector)
    end
    return λ
end

"""
Returns user buy or no buy decision given timestep, user requested product, agent selected action.
Probability is based on the unit price of the product.
"""
function user_buy(m::PMDPv2, prod::Product, a::Action, t::Timestep, rng::AbstractRNG)
    if prod != m.P[1]
        unit_price = sum(prod)/a
        d_user_buy = Categorical([pwl(unit_price), 1-pwl(unit_price)])
        buy = rand(rng, d_user_buy)==1
    else
        buy = false
    end
    return buy
end

"""
Returns next requested product. 
"""
function next_request(m::PMDPv2, t::Timestep, rng::AbstractRNG)
    if t in m.selling_period_end
        set_product_request_p!(m.product_request_p, t, m.λ, m.selling_period_end)
    end

    d_demand_model = Categorical(m.product_request_p)
    prod_index = rand(rng, d_demand_model)
    return ind2prod(prod_index, m.P)
end


function POMDPs.gen(m::PMDPv2, s, a, rng)
    if user_buy(m, s.p, a, s.t, rng)
        r = a
        c = s.c-s.p
    else
        r = 0
        c = s.c
    end
    prod = next_request(m, s.t, rng)
    Δt = 1
    while sum(prod)==0
        prod = next_request(m, s.t, rng)
        Δt += 1
    end
    return (sp = State(c, s.t+Δt, prod), r = r)
end

function POMDPs.isterminal(m::PMDPv2, s::State)
    if s.t>m.T || sum(s.c.<=0)>0 
        return true
    else
        return false
    end
end

function POMDPs.discount(m::PMDPv2)
    return 0.99
end

# POMDPs.actions(m::PMDPv2) = Float64[1:5:100;]
function POMDPs.actions(m::PMDPv2, s::State)
    if sum(s.p)<=0
        return Float64[0]
    else
        return Float64[0:5:100;]
    end
end

POMDPs.initialstate_distribution(m::PMDPv2) = Deterministic(State(SA[5,5,5,5,5], 0, SA[0,0,0,0,0]))

# PMDPv2() = PMDPv2(30)