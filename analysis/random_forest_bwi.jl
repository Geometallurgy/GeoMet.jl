using CSV
using DataFrames
using GeoMet
using Statistics
using DecisionTree
using Plots

# --- Load data ---
url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
df = CSV.read(download(url), DataFrame)

# --- Calculate BWI ---
df.BWI = calculate_bwi(df)

# --- Prepare features (X) and target (y) ---
features = [:F80, :P80, :M, :A]
X = convert(Matrix, df[:, features])
y = df.BWI

# --- Train Random Forest Regressor ---
model = DecisionTree.RandomForestRegressor(n_trees=100)
fit!(model, X, y)

# --- Make predictions ---
predictions = predict(model, X)

# --- Evaluate performance ---
mae = mean(abs.(predictions .- y))
println("Mean Absolute Error (MAE): ", round(mae, digits=3))

# --- Feature importance ---
importances = feature_importances(model)
println("Feature importances:")
for (feat, imp) in zip(features, importances)
    println("  ", feat, ": ", round(imp, digits=3))
end

# --- Plot actual vs predicted ---
scatter(y, predictions, xlabel="Actual BWI", ylabel="Predicted BWI", title="Random Forest: Actual vs Predicted")
plot!(identity, lw=2, linecolor=:red)  # y=x reference line
savefig("analysis/random_forest_actual_vs_predicted.png")
