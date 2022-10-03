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