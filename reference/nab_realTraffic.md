# Numenta Anomaly Benchmark (NAB) realTraffic

Data collection with real-world time-series. Real data from online data
traffic with anomalies As part of the Numenta Anomaly Benchmark (NAB),
this dataset contains time series with real and synthetic data. The real
data comes from network monitoring and cloud computing. On the other
hand, synthetic data simulate series with or without anomalies. See
[cefet-rj-dal/united](https://github.com/cefet-rj-dal/united) for
detailed guidance on using this package and the other datasets available
in it. Labels available? Yes

## Usage

``` r
data(nab_realTraffic)
```

## Format

A list of time series.

## Source

[Numenta Anomaly Benchmark (NAB)
Dataset](https://github.com/numenta/NAB/tree/master/data)

## Details

This package ships a mini version of the dataset. Use loadfulldata() to
download and load the full dataset from the URL stored in attr(url).

## References

Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly detection
algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th International
Conference on Machine Learning and Applications (ICMLA).

## Examples

``` r
data(nab_realTraffic)
nab_grp <- nab_realTraffic[[1]]
serie <- nab_grp[[1]]
```
