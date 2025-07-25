module GeoMet

using DataFrames # Import DataFrames for data manipulation
using DecisionTree  # Import DecisionTree for Random Forest

#Export the functions to be used outside the module
export calculate_mih
export calculate_bwi 
export calculate_specific_energy_morrell
export random_forest_model  
export calculate_mic 
export calculate_mia_energy
export run_ridge_regression
#---------------------------------------------------------------------------------------

"""
Calculate the Bond Work Index (BWI)
"""

function calculate_bwi(F80::Real, P80::Real, M::Real, A::Real)
    if any(x <= 0 for x in (F80, P80, M, A))
        throw(ArgumentError("All parameters must be positive"))
    end
    denominator = A^0.23 * M^0.82 * ( (10 * P80^-0.5) - (10 * F80^-0.5) )
    if denominator == 0
        throw(ArgumentError("Denominator zero: check F80 and P80"))
    end
    return 49 / denominator
end

# DataFrames version
function calculate_bwi(df::AbstractDataFrame; F80=:F80, P80=:P80, M=:M, A=:A)
    return calculate_bwi.(df[!,F80], df[!,P80], df[!,M], df[!,A])
end
#------------------------------------------------------------------------------
"""
Calculate the specific energy of comminution using Morrell's Equation.
Returns energy in kWh/t (kilowatt-hours per ton)
"""
function calculate_specific_energy_morrell(F80::Real, P80::Real, Mi::Real)
    if any(x -> x <= 0, (F80, P80, Mi))
        throw(ArgumentError("F80, P80, and Mi must be positive values."))
    end
    if F80 == P80
        throw(ArgumentError("F80 and P80 must be different."))
    end

    # Convert microns to meters (1e-6) and adjust units to get kWh/t
    f(x) = (0.295 + x * 1e-6) / (x * 1e-6)  # x in microns
    
    energy = Mi * 4 * (f(P80) - f(F80)) * 1e-3  # Convert to kWh/t
    
    return energy
end

# dataframes version
function calculate_specific_energy_morrell(df::AbstractDataFrame; F80=:F80, P80=:P80, Mi::Symbol=:Mi)
    return calculate_specific_energy_morrell.(df[!, F80], df[!, P80], df[!, Mi])
end

#--------------------------------------------------------------------------------------------
# Calculate MIC
function calculate_mic(A::Real, b::Real)
    if any(x -> x <= 0, (A, b))
        throw(ArgumentError("All parameters must be positive"))
    end
    return 296.81 * (A * b)^-1
end

# DataFrames version
function calculate_mic(df::AbstractDataFrame; A::Symbol, b::Symbol)
    return calculate_mic.(df[!, A], df[!, b])
end

#--------------------------------------------------------------------------------------------
"""
random_forest_model(df::DataFrame, target::Symbol; n_trees::Int=100)

Train a Random Forest regressor using all columns except the target as features.

# Arguments
- `df::DataFrame`: input dataset
- `target::Symbol`: column name of the target variable
- `n_trees::Int=100`: number of trees to use (default 100)

# Returns
- `model`: trained Random Forest model
"""
function random_forest_model(df::DataFrame, target::Symbol; n_trees::Int=100)
    features = names(df, Not(target))
    numeric_features = filter(name -> eltype(df[!, name]) <: Number, features)
    X = Matrix(df[:, numeric_features])
    # Extract feature matrix excluding target
    y = df[:, target]                             # Extract target vector

    model = DecisionTree.RandomForestRegressor(n_trees=n_trees)
    fit!(model, X, y)

    return model
end

#--------------------------------------------------------------------------------------------
# Calculate MIA

function calculate_mia_energy(F80::Real, P80::Real, Mi::Real, K::Real; circuit_type::String="SAG")
    if any(x -> x <= 0, (F80, P80, Mi, K))
        throw(ArgumentError("F80, P80, Mi, and K must be positive."))
    end
    
    f(x) = (0.295 + x * 1e-6) / (x * 1e-6) 
    
    circuit_factor = Dict("SAG" => 1.0, "AG" => 1.1, "Ball" => 0.9)[circuit_type]
    
    energy = K * circuit_factor * Mi * 4 * (f(P80) - f(F80)) * 1e-3 
    
    return energy
end

function calculate_mia_energy(df::AbstractDataFrame; F80=:F80, P80=:P80, Mi=:Mi, K=:K, circuit_type::String="SAG")
    return calculate_mia_energy.(df[!, F80], df[!, P80], df[!, Mi], df[!, K]; circuit_type=circuit_type)
end



#--------------------------------------------------------------------------------------------
# Calculate MIH
"""
calculate_mih(A::Real, b::Real)

Calculates the High Pressure Grinding Roll (HPGR) specific energy index (MIH),
which estimates how difficult a material is to comminute in HPGRs.

# Arguments
- `A::Real`: parameter A from the drop weight test
- `b::Real`: parameter b from the drop weight test

# Returns
- `MIH` value as Float64
"""
function calculate_mih(A::Real, b::Real)
    if any(x -> x <= 0, (A, b))
        throw(ArgumentError("All parameters must be positive"))
    end
    return 577.37 * (A * b)^-1.00
end

# DataFrames version
"""
calculate_mih(df::AbstractDataFrame; A::Symbol, b::Symbol)

Vectorized version of `calculate_mih` for use with DataFrames.
"""
function calculate_mih(df::AbstractDataFrame; A::Symbol, b::Symbol)
    return calculate_mih.(df[!, A], df[!, b])
end
#--------------------------------------------------------------------------------------------
using Statistics, MultivariateStats

"""
    run_ridge_regression(X::Matrix{Float64}, y::Vector{Float64}; lambda::Float64=0.01)

Run Ridge regression using MultivariateStats.jl and return predicted values.
This function assumes that X and y are preprocessed matrices/vectors.
"""
function run_ridge_regression(X::Matrix{Float64}, y::Vector{Float64}; lambda::Float64=0.01)
    model = fit(LinearModel, X, y; bias=true, lambda=lambda)
    intercept = model.bias
    weights = model.coeffs
    return intercept .+ X * weights
end

"""
    run_ridge_regression(df::DataFrame, target::Symbol, features::Vector{Symbol}; lambda::Float64=0.01)

Run Ridge regression on a DataFrame using specified target and features.

- `df`: A DataFrame containing the data.
- `target`: Symbol representing the dependent variable.
- `features`: Vector of Symbols for the independent variables.
"""
function run_ridge_regression(df::DataFrame, target::Symbol, features::Vector{Symbol}; lambda::Float64=0.01)
    X = Matrix(df[:, features])
    y = df[:, target]
    return run_ridge_regression(X, y; lambda=lambda)
end

#--------------------------------------------------------------------------------------------------------------------------------------------------------
end
