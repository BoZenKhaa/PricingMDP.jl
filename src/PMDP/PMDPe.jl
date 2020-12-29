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
    pp::PMDPProblem
    nᵣ::Int64
    empty_product::Product
    empty_product_id::Int64
    statelinearindices::LinearIndices # ONLY FOR EXPLICIT, replaces need for states array
    
    function PMDPe(pp::PMDPProblem)
        T = selling_period_ends[1]
        empty_product=P[1]
        @assert objective in [:revenue, :utilization]
        sli = stateindices(E, T, P)
        pi = productindices(P)
        return new(length(E), T,E,P,λ, selling_period_ends, empty_product, A, B, objective, sli, pi)
    end
end

function POMDPs.transition(m::PMDPe, s::State, a::Action)
    # --- Request arrival probs
    product_request_d = product_request_dist(s.t, m.λ, m.selling_period_ends)
    
    # NEXT STATES
    # No sale due to no request or due to insufficient capacity
    if  sale_impossible(m, s) 
        sps = [State(s.c, s.t+1, prod) for prod in m.P]
        probs = product_request_d.p
    else
        prob_sale = sale_prob(m, s, a)

        # sufficient capacity for sale and non-empty request
        sps_nosale = [State(s.c, s.t+1, prod) for prod in m.P]
        probs_nosale = product_request_d.p .* (1-prob_sale)

        sps_sale = [State(s.c-s.p, s.t+1, prod) for prod in m.P]
        probs_sale = product_request_d.p .* prob_sale

        sps = vcat(sps_nosale, sps_sale)
        probs = vcat(probs_nosale, probs_sale)
    end

    @assert sum(probs) ≈ 1.
    
    return SparseCat(sps, probs)
end

function POMDPs.reward(m::PMDPe, s::State, a::Action, sp::State)
    if objective(m) == :revenue
        s.c==sp.c ? 0. :  a
    elseif objective(m) == :utilization
        s.c==sp.c ? 0. :  sum(s.p)
    end
end


function POMDPs.stateindex(m::PMDPe, s::State)
    ci = CartesianIndex((s.c.+1)..., s.t+1, index(m, s.p))
    m.statelinearindices[ci]
end

function POMDPs.actionindex(m::PMDP, a::Action)
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