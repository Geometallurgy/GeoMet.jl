module GeoMet

using DataFrames # Import DataFrames for data manipulation
using DecisionTree  # Import DecisionTree for Random Forest
using LsqFit # Import lsqFIt for non-linear least squares fitting

#Export the functions to be used outside the module
export calculate_mih
export calculate_bwi 
export calculate_specific_energy_morrell
export random_forest_model  
export calculate_mic 
export calculate_mia_energy
export run_ridge_regression, LinearModel
export calculate_Ab

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
    # Validate numeric parameters
    if any(x -> x <= 0, (F80, P80, Mi, K))
        throw(ArgumentError("F80, P80, Mi and K must be positive."))
    end
    if F80 == P80
        throw(ArgumentError("F80 and P80 must be different to avoid division by zero."))
    end

    # Auxiliary calculation function
    f(x) = (0.295 + x * 1e-6) / (x * 1e-6)

    # Circuit type factors
    circuit_dict = Dict("SAG" => 1.0, "AG" => 1.1, "Ball" => 0.9)

    # Circuit type validation
    if !haskey(circuit_dict, circuit_type)
        throw(ArgumentError("Invalid circuit type. Use 'SAG', 'AG' or 'Ball'."))
    end

    # Energy calculation
    circuit_factor = circuit_dict[circuit_type]
    energy = K * circuit_factor * Mi * 4 * (f(P80) - f(F80)) * 1e-3

    return energy
end

# DataFrame version (must be defined outside the previous one)
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

struct LinearModel
    coefficients::Vector{Float64}
    intercept::Float64
end

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
"""
calculate_Ab(th_values::Vector{<:Real}, e_values::Vector{<:Real})

calculates the A and b parameters by minimizing the sum of squared errors
for the model t = A * (1 - exp(-b * e)), using excel solver logic.

#arguments
-th_values::Vector{<:Real}: Vector of observed t values (th1, th2, th3).
-e_values::Vector{<:Real}: Vector of energy values (e1, e2, e3).

#returns
- tuple{float64, float64}: a tuple containing the calculated A and b parameters.
"""
function calculate_Ab(th_values::Vector{<:Real}, e_values::Vector{<:Real})
    if length(th_values) != 3 || length(e_values) != 3
        throw(ArgumentError("th_values and e_values must contain exactly 3 elements."))
    end
    if any(x -> x <= 0, e_values)
        throw(ArgumentError("All e_values must be positive."))
    end

    # define the model function for t
    model_t(A, b, e) = A * (1 - exp(-b * e))

    # define the objective function to minimize (sum of squared errors)
    function objective(p, th_obs, e_vals)
        A, b = p
        t1_calc = model_t(A, b, e_vals[1])
        t2_calc = model_t(A, b, e_vals[2])
        t3_calc = model_t(A, b, e_vals[3])

        error1 = (th_obs[1] - t1_calc)^2
        error2 = (th_obs[2] - t2_calc)^2
        error3 = (th_obs[3] - t3_calc)^2

        return error1 + error2 + error3
    end

    # initial guess for A and b
    # based on excel solver constraints: A <= 200, b >= 0.01
    p0 = [100.0, 0.1]

    # define lower and upper bounds for A and b based on excel solver constraints
    lower_bounds = [0.0, 0.01] # A >= 0, b >= 0.01
    upper_bounds = [200.0, Inf] # A <= 200, b can be anything above 0.01

    # perform the non-linear least squares fit with bounds
    fit = LsqFit.curve_fit((e, p) -> [model_t(p[1], p[2], e[1]), model_t(p[1], p[2], e[2]), model_t(p[1], p[2], e[3])],
                           e_values, th_values, p0, lower=lower_bounds, upper=upper_bounds)

    # extract the optimized parameters
    A_val = coef(fit)[1]
    b_val = coef(fit)[2]

    return A_val, b_val
end

# dataFrames version (assuming each row contains th1, th2, th3 and e1, e2, e3)
"""
calculate_Ab(df::AbstractDataFrame; th_cols::Vector{Symbol}, e_cols::Vector{Symbol})

vectorized version of `calculate_Ab` for use with DataFrames.

# arguments
- df::AbstractDataFrame: input dataframe.
- th_cols::Vector{Symbol}: column names for observed t values (th1, th2, th3).
- e_cols::Vector{Symbol}: Column names for energy values (e1, e2, e3).

# returns
- dataframe: a dataframe with calculated A and b parameters for each row.
"""
function calculate_Ab(df::AbstractDataFrame; th_cols::Vector{Symbol}, e_cols::Vector{Symbol})
    A_vals = Float64[]
    b_vals = Float64[]

    for i in 1:nrow(df)
        th_row = [df[i, th_cols[1]], df[i, th_cols[2]], df[i, th_cols[3]]]
        e_row = [df[i, e_cols[1]], df[i, e_cols[2]], df[i, e_cols[3]]]
        
        A, b = calculate_Ab(th_row, e_row)
        push!(A_vals, A)
        push!(b_vals, b)
    end

    return DataFrame(A=A_vals, b=b_vals)
end

end
