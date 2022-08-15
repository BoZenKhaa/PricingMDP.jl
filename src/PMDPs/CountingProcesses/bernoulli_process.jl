
abstract type DiscreteCountingProcess <: Sampleable{Multivariate,Discrete} end

struct BernouliProcess <: DiscreteCountingProcess
    n::Int64
    p::Float64
    # domain::Tuple

    inter_arrival_distribution::Distribution
    success_distribution::Distribution

    function BernoulliProcess(n::Int64, p::Float64)
        new(n, p, Geometric(p), Bernoulli(p))
    end
end

rand(bp::BernouliProcess) = rand(bp.inter_arrival_distribution)
rand(bp::BernouliProcess, t::Int64) = rand(bp.success_distribution)
params(bp::BernouliProcess) = (bp.n, bp.p)
