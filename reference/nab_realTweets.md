# Numenta Anomaly Benchmark (NAB) realTweets

Real-world time series with labeled anomalies from Twitter volumes
(NAB). Labels available: Yes. See
[cefet-rj-dal/united](https://github.com/cefet-rj-dal/united) for
detailed guidance on using this package and the other datasets available
in it. Labels available? Yes

## Usage

``` r
data(nab_realTweets)
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
data(nab_realTweets)
s <- nab_realTweets[[1]]
plot(ts(s$value), main = names(nab_realTweets)[1])

mean(s$event)
#> [1] 0
```
