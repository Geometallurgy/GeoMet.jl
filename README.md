# GeoMet.jl

**GeoMet.jl** is a fully written in Julia framework for modeling and calculating geometallurgical metrics.  
It currently supports the calculation of the **Bond Work Index (BWI)** for mineral processing, based on particle size, material density, and a constant.

[![Build Status](https://github.com/GeoMet-jl/GeoMet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GeoMet-jl/GeoMet.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Features

- Calculate Bond Work Index (BWI) using scalar values or DataFrames
- Input validation to ensure safe calculations

## Installation

To install GeoMet.jl, run the following in the Julia REPL:

```julia
] add GeoMet
