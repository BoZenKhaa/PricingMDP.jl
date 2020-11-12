using Distributions

struct BudgetPerUnit <: UserBudget
    β::Distribution
end

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

# """
# Returns user buy or no buy decision given timestep, user requested product, agent selected action.
# Probability is based linear in the size of the product, i.e. based on the unit price.
# """
# function user_buy(m::PMDP, prod::Product, a::Action, t::Timestep, rng::AbstractRNG)
#     if prod != m.empty_product
#         prob_sale = prob_sale_linear(prod, a)
#         d_user_buy = Categorical([prob_sale, 1-prob_sale])
#         buy = rand(rng, d_user_buy)==1
#     else
#         buy = false
#     end 
#     return buy
# end


# user_budget_per_unit = Distributions.Uniform(5,30)
# pdf.(b, [0:5:35])
# ccdf.(b, [0:5:35])

# function get_user_budget()

# end

"""
Given budget per unit, calculate price per unit and determine probability of sale using complementary cdf of user budgets.

TODO: Add functionality for non-linear user budget.
"""
function sale_prob(m::PMDP, s::State, a::Action)
    prod_size = sum(s.p)
    @assert prod_size>0
    ccdf(m.B.β, a/prod_size)
end

"""
Sample user budget Budget is linear in the size of the product, i.e. based on the unit price.

TODO: Add functionality for non-linear user budget
"""
function sample_customer_budget(m::PMDP, s::State, rng::AbstractRNG)::Float64
    # local b::Float64
    if s.p d!= m.P[1]
        budget_per_unit_d = m.B.β
        budget_per_unit = rand(rng, budget_per_unit_d)
        b = sum(s.p)*budget_per_unit
    else
        b = -1.
    end
    return b
end