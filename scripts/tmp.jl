# Of note: https://jkrumbiegel.com/pages/2020-10-31-tuples-and-vectors/
# Also: https://discourse.julialang.org/t/hash-function-for-immutable-struct-containing-mutable-vectors/68326/3
# Also: https://stackoverflow.com/questions/27661255/hash-instability-in-julia-composite-types
# Also: https://github.com/andrewcooke/AutoHashEquals.jl


using StaticArrays

struct MyStruct
    v::Vector{Int64}
end

struct MySStruct
    v::SVector{2,Int64}
end

println([1,2]==[1,2]) # true
println(SA[1,2]==SA[1,2]) # true

println(MyStruct([1,2]) == MyStruct([1,2])) # false
println(MySStruct([1,2]) == MySStruct([1,2])) # true

isbits([1,2])


# Avoid allocations
using BenchmarkTools

function has_capacity_for_product_minus(c::Vector, p::Vector)::Bool
    for v in (c-p)
        if v < 0 
            return false
        else 
            continue
        end
    end
    return true
end

function has_capacity_for_product_zip(c::Vector, p::Vector)::Bool
    for (vc, vp) in zip(c,p)
        if vc-vp < 0 
            return false
        else 
            continue
        end
    end
    return true
end

function has_capacity_for_product_gen(c::Vector, p::Vector)
    return !any(vc-vp < 0 for (vc,vp) in zip(c,p))
end

N=10^8
a = ones(Int64, N)  
b = ones(Int64, N)  

@btime has_capacity_for_product_minus(a,b)
@btime has_capacity_for_product_zip(a,b)
@btime has_capacity_for_product_gen(a,b)

@code_lowered has_capacity_for_product_gen(a,b)
@code_lowered has_capacity_for_product_zip(a,b)
@code_lowered has_capacity_for_product_minus(a,b)

@code_warntype has_capacity_for_product_gen(a,b)

@code_native has_capacity_for_product_gen(a,b)

using JET

@report_opt has_capacity_for_product_gen(a,b)
