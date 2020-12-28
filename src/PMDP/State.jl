function State(c::AbstractArray, t::Timestep, iₚ::Integer)
    size = length(c)
    State{size}(SVector{size}(c), t, iₚ) 
end

function State(m::PMDP, c::AbstractArray, t::Timestep, product::Array)
    size = length(c)
    iₚ = findfirst(x-> x==product, products(m))
    State{size}(SVector{size}(c), t, iₚ)
end

function product(m::PMDP, s::State)
    products(m)[s.iₚ]
end

function show(io::IO, s::State)
    print(io, "c:$(s.c)_t:$(s.t)_p:$(s.iₚ)")
end

