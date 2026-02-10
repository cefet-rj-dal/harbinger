# Yahoo Webscope S5 – A1 Benchmark (Real)

Part of the Yahoo Webscope S5 labeled anomaly detection dataset. A1
contains real-world time series with binary anomaly labels. Useful for
evaluating anomaly detection methods on real traffic-like data. Labels
available: Yes.

## Usage

``` r
data(A1Benchmark)
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

Chandola, V., Banerjee, A., & Kumar, V. (2009). Anomaly detection: A
survey. ACM Computing Surveys, 41(3), 1–58.

## Examples

``` r
data(A1Benchmark)
# Access the first series and visualize
s <- A1Benchmark[[1]]
plot(ts(s$value), main = names(A1Benchmark)[1], ylab = "value")

mean(s$event)  # proportion of labeled anomalies
#> [1] 0
```
