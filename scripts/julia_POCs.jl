# # Assigning concrete function call to a method saves the function, not the result.
# module functions
# function factorial(n)
#     if n>1
#         return n*factorial(n-1)
#     elseif n==1
#         return 1
#     end
# end

# using BenchmarkTools

# fn = factorial(15)



# special() = factorial(15)
# special2() = fn

# @benchmark factorial(15)
# @benchmark special()
# @benchmark special2()

# end


# # define vector interface for custom struct
# module vectorinterface_poc

# using StaticArrays

# struct mysv{Size} <: StaticArray{Tuple{Size}, Bool, 1}
#     v::SVector{Size, Bool}
#     meta::String
# end

# @inline Tuple(m::mysv) = m.v.data
# StaticArrays.@propagate_inbounds function Base.getindex(m::mysv, i::Int) 
#     m.v.data[i]
# end

# a = mysv{2}(SVector(false, false), "aha")
# b = SVector(true, true)

# @show b+a
# end

# # traits
# module traits
# using SimpleTraits

# abstract type Superbtype end

# struct maintype <: Superbtype 
#     a::Int
# end

# struct otherype <: Superbtype 
#     a::Int
#     b::String
# end
# end

# # Comparing speed of rng
# using Random
# using BenchmarkTools

# rngm = MersenneTwister(1)
# rngx = Xoshiro(1)
# rngx2 = Xoshiro(1)

# @benchmark MersenneTwister(1)
# @benchmark Xoshiro(1)
# @benchmark Xoshiro(1)

# @benchmark rand(rngm)
# @benchmark rand(rngx)
# @benchmark rand(rngx2)

# # Try-catch block scope issues

# function test_trycatch()
#     a = "outer"
#     try
#         a = "try"
#         throw(ErrorException("Oh no!"))
#     catch
#         a = "catch" 
#     end

#     a
# end

# test_trycatch()

# # plotting functions
# using Plots

# # f(x) = log.(x)

# x = 1:100
# plot(x, .(log.(x)))
# plot(x, sqrt.(log.(x)))
# plot!(x, sqrt.(log.(x)/10))
# plot!(x, sqrt.(log.(x)/100))

# C,α = (1, 0.1)
# plot(x,C.*x.^α)


# # BSON Dict bug?
# using BSON
# using FileIO

# inner_d = Dict(:v=>0)
# outer_d = Dict(:d=>inner_d)
# save("test.bso", outer_d)
# display(inner_d)
# load("test.bson")

# v = [zeros(1) for i in 1:2]
# D = Dict(:d=>v)
# save("test_v.bson", D)
# BSON.load("test_v.bson")

# JLD issues
using JLD
using StaticArrays

struct MyType{N}
    a::SVector{N,Int64}
end

MyType{2}(SA[1, 2])

struct MyType2{T}
    a::SVector{2,T}
end

struct MyType3{T}
    a::T
end

struct MyType4{T}
    b::MyType3{T}
end

MyType4{Int64}(MyType3{Int64}(1))

JLD.save("test.jld", "s", MyType4{Int64}(MyType3{Int64}(1)))
load("test.jld")
