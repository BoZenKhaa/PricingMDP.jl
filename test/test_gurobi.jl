using Gurobi
using JuMP

# GOOD
model = Model(Gurobi.Optimizer)
@variable(model, x[1:100] >= 0)
for i = 1:100  # all modifications are done before any queries
    set_upper_bound(x[i], i)
end
for i = 1:100 # only the first `lower_bound` query may trigger an `update_model!` 
    println(lower_bound(x[i]))
end