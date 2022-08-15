"""
Stuct that defines the pricing MDP problem
"""
struct PMDPProblem{Objective}
    P::Vector{Product}      # Products array  
    c₀::Vector{Int64}       # Initial capacity of resources
    T::Timestep                  # Number of timesteps
    D::DiscreteCountingProcess   # Demand for each product 
    B::Vector{Distribution} # Budget distributions for each product
    A::Vector{Action}       # Action array (including reject action)
    info::NamedTuple
    objective::Symbol            # objective for optimization

    function PMDPProblem(
        non_empty_P::AbstractVector{<:Product},
        c₀,
        D,
        B,
        real_actions,
        objective;
        info = (;),
    )
        T = problem_selling_horizon(non_empty_P)
        A = [real_actions..., REJECT_ACTION]
        @assert objective in [:revenue, :utilization]
        @assert are_unique(non_empty_P)
        new{objective}(
            non_empty_P,
            c₀,
            T,
            D,
            B,
            A,
            info,
            objective,
        )
    end
end



"""
Get number of products, resources, and actions
"""
Base.size(pp::PMDPProblem) = (length(pp.P), length(pp.P[1]), length(pp.A))
n_products(pp::PMDPProblem) = size(pp)[1]
n_resources(pp::PMDPProblem) = size(pp)[2]
n_actions(pp::PMDPProblem) = size(pp)[3]

function problem_selling_horizon(P::AbstractArray{<:Product})::Timestep
    maximum([p.selling_period_end for p in P])
end

selling_period_end(p::PMDPProblem) = p.T

empty_product(p::PMDPProblem) = Product(falses(n_resources(p)), selling_period_end(p))

function statespace_size(p::PMDPProblem; verbose=true) 
    state_size_bytes = Base.summarysize(empty_product(p))
    n_c = prod(p.c₀)
    n_T = selling_period_end(p)
    n_P = n_products(p)

    n_states = n_c*n_T*n_P
    if verbose
        println("There are $(n_c) capacity vectors, $(n_T) timesteps, and $(n_P) products")
        println("For $(n_states) states, each state is $(state_size_bytes) bytes")
        println("These would take $(n_states*state_size_bytes/(1000^3)) GB of memory")
    end
    return n_states, state_size_bytes
end
