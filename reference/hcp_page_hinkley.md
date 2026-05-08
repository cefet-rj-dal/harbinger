# Page-Hinkley change-point detector

Online change-point detection for univariate time series using the
classical Page-Hinkley statistic. The detector accumulates deviations
from the running mean and raises a changepoint when the cumulative score
crosses the configured threshold.

This implementation is restricted to univariate numeric series. It is
meant to capture virtual drift on the observed signal directly, without
any classifier or multivariate preprocessing.

## Usage

``` r
hcp_page_hinkley(
  min_instances = 30,
  delta = 0.005,
  threshold = 50,
  alpha = 1 - 1e-04
)
```

## Arguments

- min_instances:

  Minimum number of observations required before a change can be
  reported.

- delta:

  Slack term subtracted from the deviation score.

- threshold:

  Detection threshold for the cumulative statistic.

- alpha:

  Forgetting factor applied to the cumulative score.

## Value

An `hcp_page_hinkley` object.

## References

- Page ES (1954). Continuous Inspection Schemes. Biometrika, 41(1/2),
  100-115.

- Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype
  Computing for Concept Drift Streams. Neurocomputing.
