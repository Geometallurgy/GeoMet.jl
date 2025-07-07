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
    # test with fictional values (Mi = 19.4, F80 = 100_000 μm, P80 = 750 μm)
   
    @test isapprox(calculate_specific_energy_morrell(100_000.0, 750.0, 19.4), 9.42, atol=0.01)

    # Test with invalid input error
    @test_throws ArgumentError calculate_specific_energy_morrell(0.0, 750.0, 19.4)
    @test_throws ArgumentError calculate_specific_energy_morrell(750.0, 750.0, 19.4)

    # Dataframes test
    df = DataFrame(F80=[100_000.0, 75_000.0], P80=[750.0, 500.0], Mi=[19.4, 18.0])
    results = calculate_specific_energy_morrell(df)
    @test isapprox(results[1], 9.42, atol=0.01)
end

