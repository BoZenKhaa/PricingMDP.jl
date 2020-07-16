module PricingMDPv2

export PMDPv2, State

using POMDPs
using StaticArrays
using POMDPModelTools
using MCTS
using Random, Distributions
using Combinatorics

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
const T = 100

struct Edge
    id::Int64
    c::Int64                    # capacity
    selling_horizon_end::Int64  
end

Product = SVector{n_edges,Bool}
Action = Float64
Timestep = Int64

function create_edges(n_edges::Int64, c::Int64, selling_horizon_ends::Array{Int64})
    edges = Array{Edge}(undef, n_edges)
    for i in 1:n_edges
        edges[i] = Edge(i, c, selling_horizon_ends[i])
    end
    return edges
end

edges = create_edges(n_edges, 5, [50,60,70,80,90])

function create_continuos_product(start_edge_id::Int64, len::Int64, total_n_edges::Int64)
    product = zeros(Bool, total_n_edges)
    for i in start_edge_id:(start_edge_id+len-1)
        product[i]=true
    end
    return Product(product)
end

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

products = create_continuous_products(edges)

struct State
    c::SVector{n_edges,Int64}   # Capacity vector
    t::Timestep                # Timestep
    p::Product    # Requested product
end

"""
Returns nothing if p not in products
"""
function prod2ind(p::Product)
    return indexin([p], products)[1]
end

function ind2prod(i::Int64)
    return products[i]
end


struct PMDPv2 <: MDP{State, Float64}
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product}
    D::Array{Float64}
    # selling_period_end::SVector{n_edges,Int64}
end

function create_product_demand(total::Float64, products::Array{Product})
    demand = fill(total/(length(products)-1), length(products)-1) 
    demand[1]=0. # product[1] is the empty product
    return demand
end

demand = create_product_demand(20., products)

"""
Returns user buy or no buy decision given timestep, user requested product, agent selected action.
Probability is based on the unit price of the product.
"""
function user_buy(m::PMDPv2, p::Product, a::Action, t::Timestep, rng::AbstractRNG)
    if p != m.P[0]
        unit_price = sum(p)/a
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
function next_demand(m::PMDPv2, t::Timestep, rng::AbstractRNG)
    if t <= m.T
        d_demand_model = Categorical([0.4,0.1,0.1,0.1,0.1,0.1,0.1])
        prod_index = rand(rng, d_demand_model)
        p = ind2prod(prod_index)
    else
        p = SA[0,0,0]
    end
    return p
end


function POMDPs.gen(m::PMDPv2, s, a, rng)
    if user_buy(m, s.p, a, s.t, rng)
        r = a
        c = s.c-s.p
    else
        r = 0
        c = s.c
    end
    p = next_demand(m, s.t, rng)
    return (sp = State(c, s.t+1, p), r = r)
end

# function POMDPs.gen(m::PMDPv2, s, a, rng)
#     d_demand_model = Categorical([m.p_customer_arrival,1-m.p_customer_arrival])
#     d_user_model = Categorical([m.p_purchase,1-m.p_purchase])
#
#     if s.t>m.T || s.c==0
#         sp = State(s.t, s.c)
#         r = 0
#     else
#         if rand(rng, d_demand_model)==1 # Customer arrives
#             if rand(rng, d_demand_model)==1 # Customer buys
#                 sp = State(s.t+1, s.c-1)
#                 r = a
#             else # Customer does not buy
#                 sp = State(s.t+1, s.c)
#                 r = 0
#             end
#         else # No user arrives
#             sp = State(s.t+1, s.c)
#             r=0
#         end
#     end
#     return (sp=sp, r=r)
# end

function POMDPs.discount(m::PMDPv2)
    return 0.99
end

POMDPs.actions(m::PMDPv2) = (0.,5.,10.,15.,20.,25.,30.,35.,70.)

POMDPs.initialstate_distribution(m::PMDPv2) = Deterministic(State(SA[4,4,4], 0, nothing))

# PMDPv2() = PMDPv2(30)

end
