# KSWIN change-point detector

Kolmogorov-Smirnov Windowing for univariate time series. The detector
keeps a sliding window, compares an early sample against the most recent
observations, and flags a changepoint when the two empirical
distributions differ significantly.

This implementation is restricted to univariate numeric series and is
intended to capture virtual drift on the signal directly, without any
classifier.

## Usage

``` r
hcp_kswin(window_size = 100, stat_size = 30, alpha = 0.005, data = NULL)
```

## Arguments

- window_size:

  Size of the sliding window.

- stat_size:

  Size of the statistic subwindow used for the KS test.

- alpha:

  Significance level for the KS test.

- data:

  Optional initial window content.

## Value

An `hcp_kswin` object.

## References

- Raab C, Heusinger M, Schleif FM (2020). Reactive Soft Prototype
  Computing for Concept Drift Streams. Neurocomputing.

- Bifet A, Gavaldà R (2007). Learning from time-changing data with
  adaptive windowing. SIAM International Conference on Data Mining.
