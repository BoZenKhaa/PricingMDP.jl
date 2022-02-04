"""
Staggered Bernoulli scheme is a generalization of Bernoulli scheme were each positive outcome is possible 
for different number of steps.

The constructor takes probabilities of succeses p_1, ... p_N-1 and 
n_1, ... n_N-1, number of steps outcome i is possible.
"""
struct StaggeredBernoulliScheme <: DiscreteCountingProcess
    n::Vector{Int64}
    p_suc::Vector{Float64}
    i_distributions::Vector{Categorical}

    function StaggeredBernoulliScheme(
        n::AbstractVector{<:Number},
        p_suc::AbstractVector{<:Number},
    )
        @assert 0 < sum(p_suc) <= 1
        # @assert issorted(n)
        
        # pre-compute the distributions
        n_max = maximum(n)
        i_distributions = Vector{Categorical}(undef, n_max)
        for i in 1:n_max
            active = n .>= i
            active_p = p_suc .* active
            i_distributions[i] = Categorical([active_p..., 1 - sum(active_p)])
        end

        new(n, p_suc, i_distributions)
    end
end

# # Distributions.jl interface (https://juliastats.org/Distributions.jl/stable/extends/)
# TODO: implment also for staggered case
# Base.length(bs::BernoulliScheme) = 2

# """
# Get step-shift of the next success and the next succes type.
# Support for step-shift is 1,2, ....
# Support for success type is 1, 2, ..., N  (N is the number of success results)
# """
# function Distributions._rand!(rng::AbstractRNG, bs::BernoulliScheme, x::AbstractVector{T}) where T <: Real
#     x[2] = Distributions.rand(rng, Categorical(bs.p_suc./sum(bs.p_suc)))
#     x[1] = Distributions.rand(rng, Geometric(sum(bs.p_suc)))+1
#     return x
# end

"""
Get parameters of the process
"""
Distributions.params(bs::StaggeredBernoulliScheme) = (bs.n, bs.p_suc)

"""
Get outcome distribution for given index. 
Support for the outcome distribution is 1...N+1. N+1 means failure.
Index can be in the range 1, ..., n (n is the number of random variables in the scheme).
"""
Base.getindex(bs::StaggeredBernoulliScheme, i::Integer) = bs.i_distributions[i]
