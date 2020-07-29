"""
    pwl(10, slope_start=5., slope_end=30.)

PieceWise Linear "step" function with slope in the middle, like so:
  1-|-----\\
    |      \\
    |       \\
  0-|-----|--\\------
    0  start end

TODO: Handle better configuration of user model in problem, now its hardcoded here.
"""
function pwl(x::Number;
            slope_start::Float64=5.,
            slope_end::Float64=30.)
    if x<slope_start
        return 1.
    elseif x>slope_end
        return 0.
    else
        return (x-slope_end)/(slope_start-slope_end)
    end
end

"""
Returns user buy or no buy decision given timestep, user requested product, agent selected action.
Probability is based on the unit price of the product.
"""
function user_buy(m::PMDP, prod::Product, a::Action, t::Timestep, rng::AbstractRNG)
    if prod != m.P[1]
        unit_price = sum(prod)/a
        d_user_buy = Categorical([pwl(unit_price), 1-pwl(unit_price)])
        buy = rand(rng, d_user_buy)==1
    else
        buy = false
    end
    return buy
end