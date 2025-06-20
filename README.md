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

##  Installation Guide

To use this package and run the interactive notebooks, you need to install both [Julia](https://julialang.org/downloads/) and [Pluto.jl](https://plutojl.org/).

### 1. Install Julia

- Visit the official Julia website: [https://julialang.org/downloads/](https://julialang.org/downloads/)
- Download the latest stable version compatible with your operating system (Windows, macOS, or Linux)
- Follow the installation instructions for your system

### 2. Install Pluto.jl

After installing Julia:

1. Open Julia (REPL)
2. Type and run the following command to install Pluto:

    ```julia
    import Pkg; Pkg.add("Pluto")
    ```

3. Then, launch Pluto with:

    ```julia
    using Pluto
    Pluto.run()
    ```

Pluto will open in your browser. From there, you can create or open interactive notebooks related to this project.

> If you're new to Julia or Pluto, we recommend checking out [Pluto.jl's website](https://plutojl.org/) for examples and documentation.
