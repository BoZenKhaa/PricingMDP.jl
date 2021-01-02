"""
Structures and functions for the EXPLICIT POMDPs.jl interface of the Pricing MDP
"""

"""
Enumerates all states for MDP
"""
function generate_states(pp::PMDPProblem)::AbstractArray{<:State}
    c_it = Iterators.product(pp.c₀...)
    s_it = Iterators.product(c_it, selling_period_end(pp), pp.P)
    states = [State(SVector(args[1]), args[2], args[3]) for args in s_it]
end

function stateindices(pp::PMDPProblem)::LinearIndices
    C_sizes = pp.c₀
    T_size = selling_period_end(pp)     # timestep starts at t=1 and goes up to t=T
    prd_sizes = n_products(pp)+1        # +1 for empty product

    LinearIndices((C_sizes..., T_size, prd_sizes))
end


"""
m = PMDPe(edges, products, λ)

PMDP for explicit interface
"""
struct PMDPe <: PMDP{State, Action}
    pp::PMDPProblem
    empty_product::Product
    empty_product_id::Int64
    statelinearindices::LinearIndices # ONLY FOR EXPLICIT, replaces need for states array
    
    function PMDPe(pp::PMDPProblem)
        sli = stateindices(pp)
        return new(pp, empty_product(pp), n_products(pp)+1, sli)
    end
end

function sale_prob(budget_distributions::AbstractArray{<:Distribution}, s::State, a::Action)
    # cdf is probabulity that the sample from distribution is below the asking price a
    1-cdf(budget_distributions[s.iₚ], a)
end

function next_states(m::PMDP, s::State, new_c::AbstractArray{<:Number})::Array{State}
    sps = [State(new_c, s.t+1, iₚ) for iₚ in 1:n_products(m)+1]
end

function POMDPs.transition(m::PMDPe, s::State, a::Action)
    # --- Request arrival probs
    product_request_probs = demand(m)[s.t].p
    
    # NEXT STATES
    # No sale due to no request or due to insufficient capacity
    if  sale_impossible(m, s, a) 
        sps = next_states(m, s, s.c)
        probs = product_request_probs
    else
        prob_sale = sale_prob(budgets(m), s, a)

        # sufficient capacity for sale and non-empty request
        sps_nosale = next_states(m, s, s.c)
        probs_nosale = product_request_probs .* (1-prob_sale)

        sps_sale = next_states(m, s, s.c-product(m, s))
        probs_sale = product_request_probs .* prob_sale

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
        s.c==sp.c ? 0. :  sum(product(m, s))
    end
end


function POMDPs.stateindex(m::PMDPe, s::State)
    ci = CartesianIndex((s.c.+1)..., s.t+1, s.iₚ)
    m.statelinearindices[ci]
end

POMDPs.actionindex(m::PMDP, a::Action) = findfirst(isequal(a), actions(m))
POMDPs.states(m::PMDP) = generate_states(problem(m))