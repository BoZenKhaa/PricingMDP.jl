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
Probability of sale which is linear in the size of the product
"""
function prob_sale_linear(product::Product, a::Action)
    unit_price = a/sum(product)
    pwl(unit_price)
end

"""
Returns user buy or no buy decision given timestep, user requested product, agent selected action.
Probability is based linear in the size of the product, i.e. based on the unit price.
"""
function user_buy(m::PMDP, prod::Product, a::Action, t::Timestep, rng::AbstractRNG)
    if prod != m.P[1]
        # TODO: What if sale woud be over the capacity?
        prob_sale = prob_sale_linear(prod, a)
        d_user_buy = Categorical([prob_sale, 1-prob_sale])
        buy = rand(rng, d_user_buy)==1
    else
        buy = false
    end
    return buy
end