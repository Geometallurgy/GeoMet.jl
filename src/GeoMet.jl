module GeoMet

using DataFrames # Import DataFrames for data manipulation
using DecisionTree  # Import DecisionTree for Random Forest

export calculate_bwi  # Exporting the function to be used outside the module
export calculate_specific_energy_charles
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
Calculate the specific energy of comminution using Charles' law.
"""
function calculate_specific_energy_charles(F80::Real, P80::Real, K::Real, n::Real)
    if any(x <= 0 for x in (F80, P80, K))
        throw(ArgumentError("F80, P80, and K must be positive"))
    end
    if F80 == P80
        throw(ArgumentError("F80 and P80 must be different to avoid zero energy result"))
    end

    return K * (1 / P80^n - 1 / F80^n)
end


# DataFrame version
function calculate_specific_energy_charles(df::AbstractDataFrame; F80=:F80, P80=:P80, K::Real=1000.0, n::Real=1.0)
    return calculate_specific_energy_charles.(df[!,F80], df[!,P80], K, n)
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
