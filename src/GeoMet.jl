module GeoMet

using DataFrames # Import DataFrames for data manipulation
using DecisionTree  # Import DecisionTree for Random Forest

export calculate_bwi  # Exporting the function to be used outside the module
export calculate_specific_energy_morrell
export random_forest_model  # Exporting the Random Forest function

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

#-------------------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------------
end
