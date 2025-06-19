# GeoMet.jl

**GeoMet.jl** is a fully written in Julia framework for modeling and calculating geometallurgical metrics.  
It currently supports the calculation of the **Bond Work Index (BWI)** for mineral processing, based on particle size, material density, and a constant.

[![Build Status](https://github.com/GeoMet-jl/GeoMet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GeoMet-jl/GeoMet.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Features

- Calculate Bond Work Index (BWI) using scalar values or DataFrames
- Input validation to ensure safe calculations

## Installation and Usage Example

# Installation (run this in Julia REPL)

```julia
] add GeoMet

```
# Usage example
```
using GeoMet

# Calculate BWI with scalar inputs
bwi = calculate_bwi(2174, 97, 0.81, 150)
println("Bond Work Index = ", bwi)

# Calculate BWI for a DataFrame
using DataFrames

df = DataFrame(F80=[2000, 1500], P80=[200, 150], M=[1.0, 1.1], A=[1.0, 1.05])
bwi_values = calculate_bwi(df)
println("BWI values for DataFrame:\n", bwi_values)
