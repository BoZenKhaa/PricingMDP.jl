using Distributions
using Random
using JET

module MTP
    export MS
    struct MS{D<:Number}
        D::Vector{D}
        function MS(D)
            new{eltype(D)}(
                D
            )
        end
    end
end


v = [Normal(0,1), Normal(0,2)]

m = MTP.MS(v)
rng = MersenneTwister(1)


function sample_request(m::MTP.MS, t::Int64, rng)
    iₚ = rand(rng, m.D[t])
end

@report_opt sample_request(m, 1, rng)