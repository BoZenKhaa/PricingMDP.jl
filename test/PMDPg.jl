@testset "PMDPg.jl" begin

    # initialize 
    pp = simple_pp()

    mg = PMDPs.PMDPg(pp)

    PMDPs.empty_product(mg) == PMDPs.Product(falses(mg.nᵣ), PMDPs.selling_period_end(pp))
end