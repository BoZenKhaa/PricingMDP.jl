using Distributions

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
Given budget per unit, calculate price per unit and determine probability of sale using complementary cdf of user budgets.

"""
function sale_prob(m::PMDP, s::State, a::Action)
    prod_size = sum(s.p)
    @assert prod_size>0
    ccdf(m.B[index(s.p)], a/prod_size)
end

"""
Sample user budget Budget is linear in the size of the product, i.e. based on the unit price.

TODO: Add functionality for non-linear user budget
"""
function sample_customer_budget(m::PMDP, s::State, rng::AbstractRNG)::Float64
    # local b::Float64
    if s.p != m.P[1]
        budget_distribution = m.B[index(s.p)]
        budget = rand(rng, budget_distribution)
    else
        budget = -1.
    end
    return budget
end