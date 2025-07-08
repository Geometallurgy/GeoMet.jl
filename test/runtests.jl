using GeoMet
using Test
using DataFrames

@testset "GeoMet.jl" begin
    # Test with known values
    @test isapprox(calculate_bwi(2174, 97, 0.81, 150), 22.9706, atol=0.001)  # atol is the absolute tolerance
    
    # Error tests
    @test_throws ArgumentError calculate_bwi(0, 200, 1.0, 1.0)  # F80 inválido
    @test_throws ArgumentError calculate_bwi(2000, 2000, 1.0, 1.0)  # Denominador zero

    # DataFrame test
    df = DataFrame(F80=[2000, 1500], P80=[200, 150], M=[1.0, 1.1], A=[1.0, 1.05])
    @test length(calculate_bwi(df)) == 2

    # Random Forest test
    df.BWI = collect(calculate_bwi(df))  # Target column
    model = random_forest_model(df, :BWI, n_trees=5)  # Train small model
    @test !isnothing(model)  # Basic check that model was trained
end
    
@testset "GeoMet.jl – Morrell Specific Energy" begin
    # Test with values from your dataframe (first row)
    F80_test = 2174.24  # μm
    P80_test = 97.11    # μm
    Mi_test = 0.808     # kWh/t
    
    # Calculate expected value manually
    f_P80 = (0.295 + P80_test*1e-6)/(P80_test*1e-6)
    f_F80 = (0.295 + F80_test*1e-6)/(F80_test*1e-6)
    expected = Mi_test * 4 * (f_P80 - f_F80) * 1e-3
    
    @test isapprox(calculate_specific_energy_morrell(F80_test, P80_test, Mi_test), expected, atol=0.01)

    # Test with invalid input error
    @test_throws ArgumentError calculate_specific_energy_morrell(0.0, 750.0, 19.4)
    @test_throws ArgumentError calculate_specific_energy_morrell(750.0, 750.0, 19.4)

    # Dataframes test
    df = DataFrame(F80=[2174.24, 2188.54], P80=[97.11, 115.51], Mi=[0.808, 0.855])
    results = calculate_specific_energy_morrell(df)
    
    # Calculate expected for first row
    @test isapprox(results[1], expected, atol=0.01)
end
