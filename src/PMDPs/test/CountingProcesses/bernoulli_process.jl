using RandomNumbers.Xorshifts
using Distributions

@testset "bernoulli_process.jl" begin
    p = [0.1, 0.1]
    n = 10

    rng = Xorshift128Plus(1)

    bs = PMDPs.CountingProcesses.BernoulliScheme(n, p)


    @test params(bs) == (10, [0.1, 0.1])
    @test params(bs[3]) == ([0.1, 0.1, 0.8],)

    samples = Matrix{Float64}(undef, 2, 1000)
    for i = 1:1000
        samples[:, i] = rand(rng, bs)
    end
    max_shift, max_outcome = maximum(samples; dims = 2)
    min_shift, min_outcome = minimum(samples; dims = 2)
    @test min_outcome == 1
    @test max_outcome == 2
    @test min_shift == 1

    nhbs = PMDPs.CountingProcesses.NonhomogenousBernoulliScheme([0.1 0.1; 0.1 0.1])[1]
end
