
abstract type DiscreteCountingProcess <: Sampleable{Multivariate, Discrete} end

struct BernouliProcess<:DiscreteCountingProcess
    n::Int64
    p::Float64
    # domain::Tuple
    
    inter_arrival_distribution::Distribution
    success_distribution::Distribution

    function BernoulliProcess(n::Int64, p::Float64)
        new(n,p, Geometric(p), Bernoulli(p))
    end
end

rand(bp::BernouliProcess) = rand(bp.inter_arrival_distribution)
rand(bp::BernouliProcess, t::Int64) = rand(bp.success_distribution)
params(bp::BernouliProcess) = (bp.n, bp.p)


"""
Bernoulli scheme is a generalization of Bernoulli proceses to dimension N where the random 
variable may take on values with probability p₁,...,p_N that sum to 1.

In our case, we assume p₁,...,p_{N-1} are probabilities of different types of success, 
p_N is the probability 

The constructor takes probabilities p_1, ... p_N-1 and calculates p_N = 1-sum_i=1^N-1(pᵢ)
"""
struct BernoulliScheme{N}<:DiscreteCountingProcess
    n::Int64
    p_suc::SVector{N, Float64}

    function BernoulliScheme(n::Int64, p_suc::AbstractArray{<:Float64})
        @assert 0<sum(p_suc)<=1
        new{length(p_suc)}(n, SA[p_suc...])
    end
end

# Distributions.jl interface (https://juliastats.org/Distributions.jl/stable/extends/)
Base.length(bs::BernoulliScheme) = 2

"""
Get step-shift of the next success and the next succes type.
Support for step-shift is 1,2, ....
Support for success type is 1, 2, ..., N  (N is the number of success results)
"""
function Distributions._rand!(rng::AbstractRNG, bs::BernoulliScheme, x::AbstractVector{T}) where T <: Real
    x[2] = Distributions.rand(rng, Categorical(bs.p_suc./sum(bs.p_suc)))
    x[1] = Distributions.rand(rng, Geometric(sum(bs.p_suc)))+1
    return x
end

"""
Get parameters of the process
"""
Distributions.params(bs::BernoulliScheme) = (bs.n, bs.p_suc)

"""
Get outcome distribution for given index. 
Support for the outcome distribution is 1...N+1. N+1 means failure.
Index can be in the range 1, ..., n (n is the number of random variables in the scheme).
"""
Base.getindex(bs::BernoulliScheme, i::Integer) = 1<=i<=bs.n ? Categorical([bs.p_suc..., 1-sum(bs.p_suc)]) : throw(BoundsError(bs, i))
