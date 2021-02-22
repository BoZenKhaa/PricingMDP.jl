"""
Staggered Bernoulli scheme is a generalization of Bernoulli scheme were each positive outcome is possible 
for different number of steps.

The constructor takes probabilities of succeses p_1, ... p_N-1 and 
n_1, ... n_N-1, number of steps outcome i is possible.
"""
struct StaggeredBernoulliScheme{N}<:DiscreteCountingProcess
    n::SVector{N, Int64}
    p_suc::SVector{N, Float64}

    function StaggeredBernoulliScheme(n::AbstractArray{<:Number}, p_suc::AbstractArray{<:Number})
        @assert 0<sum(p_suc)<=1
        # @assert issorted(n)
        new{length(p_suc)}(SA[n...], SA[p_suc...])
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
function Base.getindex(bs::StaggeredBernoulliScheme, i::Integer) 
    if 1<=i<=maximum(bs.n)
        active = bs.n .>= i
        active_p = bs.p_suc .* active
        return Categorical([active_p..., 1-sum(active_p)])
    else
        throw(BoundsError(bs, i))
    end
end