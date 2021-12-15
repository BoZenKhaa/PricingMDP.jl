function State(c::AbstractArray, t::Timestep, iₚ::Integer)
    size = length(c)
    State{size}(SVector{size}(c), t, iₚ)
end

function State(m::PMDP, c::AbstractArray, t::Timestep, product::AbstractArray)
    size = length(c)
    product == empty_product(m) ? iₚ = empty_product_id(m) :
    iₚ = findfirst(x -> x.res == product, products(m))
    State{size}(SVector{size}(c), t, iₚ)
end

function product(m::PMDP, s::State)
    s.iₚ == empty_product_id(m) ? empty_product(m) : products(m)[s.iₚ]
end

function show(io::IO, s::State)
    print(io, "c:$(s.c)_t:$(s.t)_p:$(s.iₚ)")
end
