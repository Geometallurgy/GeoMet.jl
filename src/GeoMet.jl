module GeoMet

using DataFrames

export calculate_bwi  # Exporting the function to be used outside the module

"""
    calculate_bwi(F80, P80, M, A)

Calculate the Bond Work Index (BWI).
"""
function calculate_bwi(F80::Real, P80::Real, M::Real, A::Real)
    if any(x <= 0 for x in (F80, P80, M, A))
        error("All parameters must be positive")
    end
    denominator = A^0.23 * M^0.82 * ( (10 * P80^-0.5) - (10 * F80^-0.5) )
    if denominator == 0
        error("Denominator zero: check F80 e P80")
    end
    return 49 / denominator
end

# DataFrames version
function calculate_bwi(df::AbstractDataFrame; F80=:F80, P80=:P80, M=:M, A=:A)
    return calculate_bwi.(df[!,F80], df[!,P80], df[!,M], df[!,A])
end

end
