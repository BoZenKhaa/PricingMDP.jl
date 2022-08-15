"""
Bernoulli scheme is a generalization of Bernoulli proceses to dimension N where the random 
variable may take on values with probability p₁,...,p_N that sum to 1.

In our case, we assume p₁,...,p_{N-1} are probabilities of different types of success, 
p_N is the probability 

The constructor takes probabilities p_1, ... p_N-1 and calculates p_N = 1-sum_i=1^N-1(pᵢ)
"""
struct NonhomogenousBernoulliScheme <: DiscreteCountingProcess
    p_matrix::Array{Float64,2}
    i_distributions::Vector{Categorical}

    function NonhomogenousBernoulliScheme(p_matrix)
        # @assert 0<sum(p_suc)<=1
        n_i =  size(p_matrix, 2)
        i_distributions = Vector{Categorical}(undef, n_i)
        for i in 1:n_i
            i_distributions[i] = Categorical([p_matrix[:, i]..., 1 - sum(p_matrix[:, i])])
        end
        new(p_matrix, i_distributions)
    end
end

"""
Get parameters of the process
"""
Distributions.params(bs::NonhomogenousBernoulliScheme) = (bs.p_matrix)

"""
Get outcome distribution for given index. 
Support for the outcome distribution is 1...N+1. N+1 means failure.
Index can be in the range 1, ..., n (n is the number of random variables in the scheme, not the number of outcomes).
"""
Base.getindex(bs::NonhomogenousBernoulliScheme, i::Integer) = bs.i_distributions[i]
