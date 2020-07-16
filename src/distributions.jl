using Distributions
using StatsPlots

bin = Binomial(50,0.1)
plot(bin)

# x = 1:10; y = rand(10,2)
# p = plot(x,y)
# z  = rand(10)
# plot!(p, x,z)

# lo, hi = quantile.(bin, [0.01,0.99])
# x = range(lo, hi; length=100)

