# Assigning concrete function call to a method saves the function, not the result.
module functions
function factorial(n)
    if n>1
        return n*factorial(n-1)
    elseif n==1
        return 1
    end
end

using BenchmarkTools

fn = factorial(15)



special() = factorial(15)
special2() = fn

@benchmark factorial(15)
@benchmark special()
@benchmark special2()

end


# define vector interface for custom struct
module vectorinterface_poc

using StaticArrays

struct mysv{Size} <: StaticArray{Tuple{Size}, Bool, 1}
    v::SVector{Size, Bool}
    meta::String
end

@inline Tuple(m::mysv) = m.v.data
StaticArrays.@propagate_inbounds function Base.getindex(m::mysv, i::Int) 
    m.v.data[i]
end

a = mysv{2}(SVector(false, false), "aha")
b = SVector(true, true)

@show b+a
end

# traits
module traits
using SimpleTraits

abstract type Superbtype end

struct maintype <: Superbtype 
    a::Int
end

struct otherype <: Superbtype 
    a::Int
    b::String
end
end

# Comparing speed of rng
using Random
using RandomNumbers.Xorshifts
using BenchmarkTools

rngm = MersenneTwister(1)
rngx = Xorshift128Plus(1)
rngx2 = Xorshift1024Plus(1)

@benchmark MersenneTwister(1)
@benchmark Xorshift128Plus(1)
@benchmark Xorshift1024Plus(1)

@benchmark rand(rngm)
@benchmark rand(rngx)
@benchmark rand(rngx2)
