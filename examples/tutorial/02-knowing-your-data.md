## Objective

This tutorial shows why understanding the dataset comes before choosing a detector. The goal is to inspect a full benchmark collection, count how many series it provides, determine whether the data are univariate or multivariate, and plot the first available signal.

## Method at a glance

Harbinger exposes benchmark datasets through packaged objects and `loadfulldata()`. Before modeling, it is useful to know the size of the collection, the shape of each series, and which signal column should be visualized first.

## What you will do

- load a packaged benchmark object
- replace the mini object with the full dataset
- count the available series
- identify whether the collection is univariate or multivariate
- plot the first signal using `har_plot()`

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough


``` r
library(harbinger)
```


``` r
# Helper to summarize the dataset structure in a consistent way
dataset_summary <- function(x) {
  first_series <- x[[1]]
  meta_cols <- c("idx", "event", "type", "seq", "seqlen")
  signal_cols <- setdiff(names(first_series), meta_cols)
  dataset_type <- if ("value" %in% names(first_series) || length(signal_cols) == 1) {
    "univariate"
  } else {
    "multivariate"
  }
  plot_column <- if ("value" %in% names(first_series)) "value" else signal_cols[1]

  list(
    n_series = length(x),
    dataset_type = dataset_type,
    signal_cols = signal_cols,
    plot_column = plot_column,
    first_series = first_series
  )
}
```


``` r
# Load a benchmark object and expand it to the full dataset
data(A1Benchmark)
A1Benchmark <- loadfulldata(A1Benchmark)
info <- dataset_summary(A1Benchmark)
info$n_series
```

```
## [1] 67
```

``` r
info$dataset_type
```

```
## [1] "univariate"
```

``` r
info$signal_cols
```

```
## [1] "value"
```


``` r
# Plot the first available signal with its labels
har_plot(
  harbinger(),
  info$first_series[[info$plot_column]],
  event = info$first_series$event
)
```

![plot of chunk unnamed-chunk-4](fig/02-knowing-your-data/unnamed-chunk-4-1.png)

## References

- Yahoo Webscope S5 benchmark documentation and downstream studies on labeled anomaly detection.
- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3

