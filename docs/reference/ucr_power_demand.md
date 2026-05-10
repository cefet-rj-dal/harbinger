# UCR Anomaly Archive – Italian Power Demand

Data collection with real-world time-series. Real power demand time
series with labeled anomalous intervals. See
[cefet-rj-dal/united](https://github.com/cefet-rj-dal/united) for
detailed guidance on using this package and the other datasets available
in it. Labels available? Yes

## Usage

``` r
data(ucr_power_demand)
```

## Format

A list of time series.

## Source

[UCR Anomaly
Archive](https://paperswithcode.com/dataset/ucr-anomaly-archive/)

## Details

This package ships a mini version of the dataset. Use loadfulldata() to
download and load the full dataset from the URL stored in attr(url).

## References

UCR Time Series Anomaly Archive. See also: Chandola, V., Banerjee, A., &
Kumar, V. (2009). Anomaly detection: A survey. ACM Computing Surveys,
41(3), 1–58.

## Examples

``` r
data(ucr_power_demand)
s <- ucr_power_demand[[1]]
summary(s$value)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   113.9   123.2   129.5   135.6   138.5   177.6 
```
