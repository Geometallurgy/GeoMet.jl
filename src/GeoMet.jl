module GeoMet

export calculate_bwi  # Exporta a função para ser usada fora do módulo

"""
    calculate_bwi(F80, P80, M, A)

Calcula o Índice de Trabalho de Bond (BWI).
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

end
