using CSV
using DataFrames
using GeoMet
using Statistics
using Plots
using StatsPlots 

# --- Block 1: Load CSV data ---
url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
df = CSV.read(download(url), DataFrame)
# This block imports required packages and loads the CSV data into a DataFrame.

# --- Block 2: Initial descriptive statistics ---
println("Descriptive statistics of the dataset:")
println(describe(df))
# Prints a summary of the dataset's variables like mean, median, and standard deviation.

# --- Block 3: Calculate BWI and basic statistics ---
df.BWI = calculate_bwi(df)
println("\nBWI statistics:")
println("Mean: ", mean(df.BWI))
println("Median: ", median(df.BWI))
println("Standard deviation: ", std(df.BWI))
# Calculates Bond Work Index for each row and prints basic stats about BWI.

# --- Block 4: Histograms of variables and BWI ---
histogram(df.F80, bins=20, title="F80 Distribution", xlabel="F80", ylabel="Frequency")
savefig("analysis/F80_histogram.png")

histogram(df.P80, bins=20, title="P80 Distribution", xlabel="P80", ylabel="Frequency")
savefig("analysis/P80_histogram.png")

histogram(df.M, bins=20, title="M Distribution", xlabel="M", ylabel="Frequency")
savefig("analysis/M_histogram.png")

histogram(df.A, bins=20, title="A Distribution", xlabel="A", ylabel="Frequency")
savefig("analysis/A_histogram.png")

histogram(df.BWI, bins=20, title="BWI Distribution", xlabel="BWI", ylabel="Frequency")
savefig("analysis/BWI_histogram.png")
# Creates histograms showing data distributions and saves them.

# --- Block 5: Boxplots to detect outliers ---
boxplot(df.F80, title="F80 Boxplot")
savefig("analysis/F80_boxplot.png")

boxplot(df.P80, title="P80 Boxplot")
savefig("analysis/P80_boxplot.png")

boxplot(df.M, title="M Boxplot")
savefig("analysis/M_boxplot.png")

boxplot(df.A, title="A Boxplot")
savefig("analysis/A_boxplot.png")

boxplot(df.BWI, title="BWI Boxplot")
savefig("analysis/BWI_boxplot.png")
# Generates boxplots to identify outliers in the variables.

# --- Block 6: Correlation matrix ---
println("\nCorrelation matrix:")
println(cor(Matrix(df[:, [:F80, :P80, :M, :A, :BWI]])))
# Calculates and prints correlation between variables.

# --- Block 7: Scatter plots for variable relationships ---
scatter(df.F80, df.BWI, xlabel="F80", ylabel="BWI", title="F80 vs BWI")
savefig("analysis/F80_vs_BWI.png")

scatter(df.P80, df.BWI, xlabel="P80", ylabel="BWI", title="P80 vs BWI")
savefig("analysis/P80_vs_BWI.png")

scatter(df.M, df.BWI, xlabel="M", ylabel="BWI", title="M vs BWI")
savefig("analysis/M_vs_BWI.png")

scatter(df.A, df.BWI, xlabel="A", ylabel="BWI", title="A vs BWI")
savefig("analysis/A_vs_BWI.png")
# Creates scatter plots to visualize relationships between variables and BWI.

