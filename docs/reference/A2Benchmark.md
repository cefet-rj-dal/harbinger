# Yahoo Webscope S5 – A2 Benchmark (Synthetic)

Part of the Yahoo Webscope S5 dataset. A2 contains synthetic time series
with labeled anomalies designed to stress-test algorithms. Labels
available: Yes.

## Usage

``` r
data(A2Benchmark)
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
data(A2Benchmark)
s <- A2Benchmark[[1]]
summary(s$value)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   13.89  265.36  521.79  512.22  766.35  975.06 
```
