### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 794525c6-71c8-4d16-af75-a5f29b059406
# importing packages
import Pkg

# ╔═╡ 0090f0a7-62c0-400e-91ea-f329cef8c9e6
# ╠═╡ show_logs = false
begin
# importing packages
	Pkg.add("GeoMet")
	Pkg.add("HTTP")
	Pkg.add("Plots")
	Pkg.add("CSV")
	Pkg.add("DataFrames")
end

# ╔═╡ 79621a26-2027-44be-8f21-f3d94a165035
# 
using HTTP, CSV, DataFrames, GeoMet, Plots

# ╔═╡ 459cece0-5149-11f0-1602-ab63aa513a17
# Title
"Application of the BWI Function"

# ╔═╡ dffd3703-9956-4cac-bdbf-8858b0b02dd8
begin
	url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
	resp = HTTP.get(url)
	csv_data = String(resp.body)
end

# ╔═╡ d6da5c21-d617-453c-a654-b4f536feceb9
### 1. Read into DataFrame

df = CSV.read(IOBuffer(csv_data), DataFrame)


# ╔═╡ 4f8bbb6b-6f49-4a85-a484-680e74fb7a07
### 2. Display the first rows
first(df, 5)


# ╔═╡ 38272a19-3a0e-48d3-966e-9c9e0d777a4c
begin
	### 3. Calculate BWI for each row
	bwi_vals = calculate_bwi(df)
	df_bwi = hcat(df, DataFrame(BWI = bwi_vals))
	first(df_bwi, 5)
	
end

# ╔═╡ b895c84f-16d6-4fd6-a0ed-b39a451496a8
### 4. Testing in the entire DF
bwi = calculate_bwi(df)


# ╔═╡ 0fcb4319-81b9-4a7a-be52-332c9e0b0234
begin
	# inspecting results
	minimum(bwi), maximum(bwi)
	
end

# ╔═╡ a6442270-54ab-47af-92ac-0148f2ac756c
begin
	histogram(bwi_vals, title="Distribuição do BWI", xlabel="BWI", ylabel="Frequência", legend=false)

	
end

# ╔═╡ Cell order:
# ╠═459cece0-5149-11f0-1602-ab63aa513a17
# ╠═794525c6-71c8-4d16-af75-a5f29b059406
# ╠═0090f0a7-62c0-400e-91ea-f329cef8c9e6
# ╠═79621a26-2027-44be-8f21-f3d94a165035
# ╠═dffd3703-9956-4cac-bdbf-8858b0b02dd8
# ╠═d6da5c21-d617-453c-a654-b4f536feceb9
# ╠═4f8bbb6b-6f49-4a85-a484-680e74fb7a07
# ╠═38272a19-3a0e-48d3-966e-9c9e0d777a4c
# ╠═b895c84f-16d6-4fd6-a0ed-b39a451496a8
# ╠═0fcb4319-81b9-4a7a-be52-332c9e0b0234
# ╠═a6442270-54ab-47af-92ac-0148f2ac756c
