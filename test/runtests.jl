using GeoMet
using Test

@testset "GeoMet.jl" begin
    # Test with known values
    @test isapprox(calculate_bwi(2174, 97, 0.81, 150), 23.023, atol=0.001)  # atol is the absolute tolerance
    
    # Error tests
    @test_throws ErrorException calculate_bwi(0, 200, 1.0, 1.0)  # F80 inválido
    @test_throws ErrorException calculate_bwi(2000, 2000, 1.0, 1.0)  # Denominador zero
    
end
