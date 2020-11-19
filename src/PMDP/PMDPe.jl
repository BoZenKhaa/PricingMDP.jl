"""
Structures and functions for the EXPLICIT POMDPs.jl interface of the Pricing MDP
"""

"""
Enumerates all states for MDP
"""
function generate_states(E, P, selling_period_ends)
    c_it = Iterators.product([0:e.c_init for e in E]...)
    s_it = Iterators.product(c_it, 0:maximum(selling_period_ends), P)
    states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
end

function stateindices(E::Array{Edge}, T::Timestep, P::Array{Product{N}, 1} where N)
    C_sizes = [e.c_init+1 for e in E]
    T_size = T+1
    prd_sizes = length(P)

    LinearIndices((C_sizes..., T_size, prd_sizes))
end



"""
m = PMDPe(edges, products, λ)

PMDP for explicit interface
"""
struct PMDPe <: PMDP{State, Action}
    n_edges::Int64
    T::Timestep                  # max timestep
    E::Array{Edge}
    P::Array{Product}
    λ::Array{Float64} # Demand vector (expected number of requests for each product = λ, we assume time interval (0,1))
    selling_period_ends::Array{Timestep} # Selling period end for each product
    empty_product::Product
    actions::Array{Action}
    B::Array{Distribution} # User budgets
    objective::Symbol
    statelinearindices::LinearIndices # ONLY FOR EXPLICIT, replaces need for states array
    productindices::Dict
    
    function PMDPe(E, P, λ, B, A, objective)
        selling_period_ends = get_product_selling_period_ends(E, P)
        T = selling_period_ends[1]
        empty_product=P[1]
        @assert objective in [:revenue, :utilization]
        sli = stateindices(E, T, P)
        pi = productindices(P)
        return new(length(E), T,E,P,λ, selling_period_ends, empty_product, A, B, objective, sli, pi)
    end
end

"""
Get product arrival probablities from homogenous Pois. proc. intensities λ, 
while considering the product selling periods.

Given λ, the expected number of request in period (0,1), 
the probability of request arrivel in given timestep is given by λ~mp where m is the number of timesteps in period (0,1).
"""
function calculate_product_request_probs(t::Timestep,  λ::Array{Float64}, selling_period_ends::Array{Timestep})
    product_request_probs = Array{Float64, 1}(undef, length(λ))
    for i in 2:length(λ)
        if t>selling_period_ends[i]
            product_request_probs[i]=0
        else
            product_request_probs[i]=λ[i]/selling_period_ends[i]
        end
    end
    product_request_probs[1] = 1.0-sum(product_request_probs[2:end])
    @assert 0. <= product_request_probs[1] <= 1. "The non-empty product request probabilities sum is > 1, finer time discretization needed."
    return product_request_probs
end

function POMDPs.transition(m::PMDPe, s::State, a::Action)
    # if s.t>=m.T
        # sps = [s]
        # probs = [1.]
    # else # t<T
        # --- Request arrival probs
        product_request_probs = calculate_product_request_probs(s.t, m.λ, m.selling_period_ends)
        
        # NEXT STATES
        # No sale due to no request or due to insufficient capacity
        if  sale_impossible(m, s) 
            sps = [State(s.c, s.t+1, prod) for prod in m.P]
            probs = product_request_probs
            # transitions = SparseCat(sps, probs)
        else
            prob_sale = sale_prob(m, s, a)

            # sufficient capacity for sale and non-empty request
            sps_nosale = [State(s.c, s.t+1, prod) for prod in m.P]
            probs_nosale = product_request_probs.*(1-prob_sale)

            sps_sale = [State(s.c-s.p, s.t+1, prod) for prod in m.P]
            probs_sale = product_request_probs.*prob_sale

            sps = vcat(sps_nosale, sps_sale)
            probs = vcat(probs_nosale, probs_sale)
        end
    # end

    @assert sum(probs) ≈ 1.
    
    return SparseCat(sps, probs)
end

function POMDPs.reward(m::PMDPe, s::State, a::Action, sp::State)
    if m.objective == :revenue
        s.c==sp.c ? 0. :  a
    elseif m.objective == :utilization
        s.c==sp.c ? 0. :  sum(s.p)
    end
end


function POMDPs.stateindex(m::PMDPe, s::State)
    ci = CartesianIndex((s.c.+1)..., s.t+1, index(m, s.p))
    m.statelinearindices[ci]
end

function POMDPs.actionindex(m::PMDPe, a::Action)
    # ind = 
    return findfirst(isequal(a), actions(m))
    # if ind===nothing
    #     println(a, ind)
    # end
    # return ind
end

function POMDPs.states(m::PMDPe)
    generate_states(m.E, m.P, m.selling_period_ends)
    # m.states
end