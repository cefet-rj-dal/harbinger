# GECCO Challenge 2018 – Water Quality Time Series

Benchmark time series for water quality monitoring composed of multiple
sensors and an associated binary event label. This dataset supports
research in anomaly and event detection for environmental data streams.
See [cefet-rj-dal/united](https://github.com/cefet-rj-dal/united) for
usage guidance and links to the preprocessing steps used to build the
package-ready object. Labels available: Yes.

## Usage

``` r
data(gecco)
```

## Format

A list of time series.

## Source

[Gecco Challenge 2018](https://www.spotseven.de/gecco/gecco-challenge/)

## Details

This package ships a mini version of the dataset. Use loadfulldata() to
download and load the full dataset from the URL stored in attr(url).

## References

Genetic and Evolutionary Computation Conference (GECCO), Association for
Computing Machinery (ACM). See also: Chandola, V., Banerjee, A., &
Kumar, V. (2009). Anomaly detection: A survey. ACM Computing Surveys,
41(3), 1–58.

## Examples

``` r
data(gecco)
# Select the first univariate series and inspect
series <- gecco[[1]]
summary(series$value)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   6.500   6.500   6.500   6.523   6.500   6.600 
# Plot values with event markers
plot(ts(series$value), main = names(gecco)[1], ylab = "value")
```
