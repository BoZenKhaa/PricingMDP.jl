using StaticArrays
using PMDPs
using Test


@testset "product.jl" begin

    p1 = PMDPs.Product(SA[true, false], 6)
    @test typeof(p1) <: PMDPs.Product

    p2 = PMDPs.Product(SA[true, true], 3)
    @test p1 + p2 == [2, 1]

    products = [
        PMDPs.Product(SA[true, false], 6),
        PMDPs.Product(SA[false, true], 8),
        PMDPs.Product(SA[true, true], 6),
    ]
    @test PMDPs.are_unique(products)

    products_not_unique = [
        PMDPs.Product(SA[true, false], 6),
        PMDPs.Product(SA[false, true], 8),
        PMDPs.Product(SA[false, true], 6),
    ]
    @test !PMDPs.are_unique(products_not_unique)
end
