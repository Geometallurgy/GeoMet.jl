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
    
@testset "GeoMet.jl – Charles Specific Energy" begin
    # Test with known values (n = 1, Rittinger)
    @test isapprox(calculate_specific_energy_charles(2000.0, 100.0, 1000.0, 1.0), 990.0, atol=0.001)

    # Test with Bond exponent (n = 0.5)
    @test isapprox(calculate_specific_energy_charles(2000.0, 100.0, 1000.0, 0.5), 292.893, atol=0.001)

    # Error tests
    @test_throws ArgumentError calculate_specific_energy_charles(0.0, 100.0, 1000.0, 1.0)  # invalid F80
    @test_throws ArgumentError calculate_specific_energy_charles(100.0, 100.0, 1000.0, 1.0)  # F80 == P80

    # DataFrame test
    df = DataFrame(F80=[2000.0, 1500.0], P80=[200.0, 150.0])
    results = calculate_specific_energy_charles(df; K=1000.0, n=1.0)
    @test length(results) == 2
    @test isapprox(results[1], 990.0, atol=0.001)
end
