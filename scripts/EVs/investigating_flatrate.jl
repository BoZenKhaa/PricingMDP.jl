using JLD2
using PMDPs

data = JLD2.load(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=768_c=3_expected_res=96_nᵣ=96_res_budget_μ=0.25\results\flatrate\config_flatrate_result.jld2")
# data = JLD2.load(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=160_c=3_expected_res=20_nᵣ=20_res_budget_μ=1.2\results\flatrate\config_flatrate_result.jld2")
data["jld2_data"][:results]
data

data["jld2_data"]




solver_cfg_filepath = raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=160_c=3_expected_res=20_nᵣ=20_res_budget_μ=1.2\results\flatrate_testing\config_flatrate.yaml"
res = PMDPs.run_solver(solver_cfg_filepath)


traces = JLD2.load(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=768_c=3_expected_res=96_nᵣ=96_res_budget_μ=0.25\traces\traces_N=100_seed=888.jld2")
# traces = JLD2.load(raw"C:\Users\mrkos\scth\projects\MDPPricing\data\ev_variable_resources\single_day_cs_pp_T=160_c=3_expected_res=20_nᵣ=20_res_budget_μ=1.2\traces\traces_N=100_seed=888.jld2")
sample = traces["jld2_data"][:traces][1:25]

pp = data["jld2_data"][:pp]
mg = PMDPg(pp)
PMDPs.get_flatrate_policy(mg, sample)

sam = sample[1]
for s in sam
    if s.s.iₚ!=4657
        println(s)
    end
end