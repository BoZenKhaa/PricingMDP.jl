"""
Structures and functions for the EXPLICIT POMDPs.jl interface of the Pricing MDP
"""

"""
Enumerates all states for MDP
"""
function generate_states(pp::PMDPProblem)::AbstractArray{<:State}
    c_it = Iterators.product([0:cᵣ for cᵣ in pp.c₀]...)
    s_it = Iterators.product(c_it, 1:selling_period_end(pp), 1:(n_products(pp)+1)) # +1 for empty_product
    try
        states = [State(collect(args[1]), args[2], args[3]) for args in s_it]
    catch e
        if isa(e, OutOfMemoryError)
            println("Not enough memory to allocate state space")
            statespace_size(pp; verbose=true)
            throw(e)
        end
    end
end

function stateindices(pp::PMDPProblem)::LinearIndices
    C_sizes = pp.c₀ .+ 1                # +1 for 0 capacity
    T_size = selling_period_end(pp)     # timestep starts at t=1 and goes up to t=T
    prd_sizes = n_products(pp) + 1        # +1 for empty product

    LinearIndices((C_sizes..., T_size, prd_sizes))
end


"""
m = PMDPe(edges, products, λ)

PMDP for explicit interface
"""
struct PMDPe <: PMDP{State,Action}
    pp::PMDPProblem
    empty_product::Product
    empty_product_id::Int64
    statelinearindices::LinearIndices # ONLY FOR EXPLICIT, replaces need for states array
    # stage_statelinearindices::LinearIndices

    function PMDPe(pp::PMDPProblem)
        sli = stateindices(pp)
        return new(pp, empty_product(pp), n_products(pp) + 1, sli)
    end
end


"""
Works only for un-empty product
"""
function sale_prob(budget_distributions::AbstractArray{<:Distribution}, s::State, a::Action)
    # cdf is probabulity that the sample from distribution is below or equal (≤) the asking price a
    # we want probability that sample is below the asking price (<). 
    # This is only issue with discrete distributions, for those, I will subtract ϵ from a.
    1 - cdf(budget_distributions[s.iₚ], a - ϵ)
end

function next_states(m::PMDP, s::State, new_c::AbstractArray{<:Number})::Array{State}
    if s.t < selling_period_end(m) # States with t=T are terminal.
        sps = [State(new_c, s.t + 1, iₚ) for iₚ = 1:n_products(m)+1] # +1 for empty_product
    else
        sps = []
    end
    return sps
end

function POMDPs.transition(m::PMDPe, s::State, a::Action)
    # --- Request arrival probs
    product_request_probs = demand(m)[s.t].p

    # NEXT STATES
    # if s.t == selling_period_end(m)
    #     sps = [s]
    #     probs = [1.]
    if sale_impossible(m, s, a)
        sps = next_states(m, s, s.c)
        probs = product_request_probs
    else # sale possible
        prob_sale = sale_prob(budgets(m), s, a)

        # sufficient capacity for sale and non-empty request
        sps_nosale = next_states(m, s, s.c)
        probs_nosale = product_request_probs .* (1 - prob_sale)

        sps_sale = next_states(m, s, s.c - product(m, s))
        probs_sale = product_request_probs .* prob_sale

        sps = vcat(sps_nosale, sps_sale)
        probs = vcat(probs_nosale, probs_sale)
    end

    @assert sum(probs) ≈ 1.0

    return SparseCat(sps, probs)
end

function POMDPs.reward(m::PMDPe, s::State, a::Action, sp::State)
    if objective(m) == :revenue
        s.c == sp.c ? 0.0 : a
    elseif objective(m) == :utilization
        s.c == sp.c ? 0.0 : sum(product(m, s))
    end
end


function POMDPs.stateindex(m::PMDPe, s::State)
    ci = CartesianIndex((s.c .+ 1)..., s.t, s.iₚ) # +1 for capacity because capaciteus go from 0..c₀
    m.statelinearindices[ci]
end

POMDPs.actionindex(m::PMDP, a::Action) = findfirst(isequal(a), actions(m))
POMDPs.states(m::PMDP) = generate_states(pp(m))
index(m::PMDPe, p::Product) = m.productindices[p]



"""
 --------------------- FINITE HORIZON -----------------------------
"""
function generate_stage_states(pp::PMDPProblem, t::Timestep)::AbstractArray{<:State}
    c_it = Iterators.product([0:cᵣ for cᵣ in pp.c₀]...)
    s_it = Iterators.product(c_it, 1:(n_products(pp)+1)) # +1 for empty_product
    states = [State(Vector(args[1]...), t, args[2]) for args in s_it]
end

function stage_stateindices(pp::PMDPProblem, t::Int64)::LinearIndices
    C_sizes = pp.c₀ .+ 1                # +1 for 0 capacity
    prd_sizes = n_products(pp) + 1        # +1 for empty product

    LinearIndices((C_sizes..., prd_sizes))
end


function FiniteHorizonPOMDPs.stage_states(mdp::PMDP, epoch::Int64)::Array{State}
    return generate_stage_states(pp(mdp), epoch)
end

function FiniteHorizonPOMDPs.stage_stateindex(mdp::PMDP, s::State, epoch::Int64)
    i = findfirst(sp -> sp.c == s.c && sp.iₚ == s.iₚ, generate_stage_states(pp(mdp), epoch))
    stage_stateindices(pp(mdp), epoch)[i]
    # findfirst(isequal(s), generate_states(pp(mdp), epoch))
end

function FiniteHorizonPOMDPs.stage_stateindex(mdp::PMDP, s::State)
    FiniteHorizonPOMDPs.stage_stateindex(mdp, s, FiniteHorizonPOMDPs.stage(s))
end

FiniteHorizonPOMDPs.stage(s::State) = s.t
FiniteHorizonPOMDPs.HorizonLength(::Type{<:PMDP}) = FiniteHorizon()
FiniteHorizonPOMDPs.horizon(mdp::PMDP) = selling_period_end(mdp)

