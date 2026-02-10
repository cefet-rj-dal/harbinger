# Yahoo Webscope S5 – A4 Benchmark (Synthetic with Anomalies and CPs)

Part of the Yahoo Webscope S5 dataset. A4 contains synthetic time series
with labeled anomalies and change points. Labels available: Yes.

## Usage

``` r
data(A4Benchmark)
```

## Format

A list of time series.

## Source

[doi:10.1371/journal.pone.0262463](https://doi.org/10.1371/journal.pone.0262463)

## Details

This package ships a mini version of the dataset. Use loadfulldata() to
download and load the full dataset from the URL stored in attr(url).

## References

Yoshihara K, Takahashi K (2022) A simple method for unsupervised anomaly
detection: An application to Web time series data. PLoS ONE 17(1).

Truong, C., Oudre, L., & Vayatis, N. (2020). Selective review of change
point detection methods. Signal Processing, 167, 107299.

## Examples

``` r
data(A4Benchmark)
s <- A4Benchmark[[1]]
mean(s$event)  # proportion of anomalous or change-point timestamps
#> [1] 0
```
