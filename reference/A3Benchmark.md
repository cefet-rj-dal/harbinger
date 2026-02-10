# Yahoo Webscope S5 – A3 Benchmark (Synthetic with Outliers)

Part of the Yahoo Webscope S5 dataset. A3 contains synthetic time series
with labeled outliers/anomalies. Labels available: Yes.

## Usage

``` r
data(A3Benchmark)
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

## Examples

``` r
library(harbinger)
data(A3Benchmark)
s <- A3Benchmark[[1]]
# Quick visualization with harbinger
har_plot(harbinger(), s$value)
```
