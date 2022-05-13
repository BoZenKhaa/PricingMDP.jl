### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ e971c692-92f8-11eb-2e0a-498f685e53e0
begin
	using BSON
	using DataFrames
	using DrWatson
	
	b = DataFrame(v = [1,2],l = ["a", "b"])
	DrWatson.save("./test.bson", Dict(:b=>b))
	
	BSON.load("./test.bson")
end

# ╔═╡ 26c93d1c-92fa-11eb-2e64-0142d836ffd4
begin
	using JLD2
	
	c = DataFrame(v = [1,2],l = ["a", "b"])
	DrWatson.save("./test.jld2", Dict("c"=>c))
	
	l = load("./test.jld2")
end
	

# ╔═╡ 8057d37c-92f8-11eb-12d4-095b8620030f
begin
    import Pkg
    Pkg.activate("..")
end

# ╔═╡ Cell order:
# ╠═8057d37c-92f8-11eb-12d4-095b8620030f
# ╠═e971c692-92f8-11eb-2e0a-498f685e53e0
# ╠═26c93d1c-92fa-11eb-2e64-0142d836ffd4
