## Custom Anomaly Detector

## Objective

The goal of this example is to show how to add a custom anomaly detector that plugs into the same Harbinger workflow used by the built-in detectors.

More importantly, the example is meant to motivate a different anomaly-detection idea than the residual- or distance-based methods already present in the package. Here the detector focuses on unusual observations that stand out as isolated temporal outliers relative to the local structure of the series.

## Why this method matters

Some anomaly detectors try to explain the full dynamics of the series and then inspect the residuals. That is powerful, but it is not always the most intuitive starting point. A simpler viewpoint is: if a point is inconsistent with the nearby temporal pattern, it may already be an anomaly even before we build a full predictive model.

That is the role of `forecast::tsoutliers()`. It searches for observations that behave like additive outliers or temporary disturbances in a time-series decomposition context. This makes it a useful custom example because:

- it introduces a classical anomaly concept that many practitioners already recognize;
- it shows how to wrap an external detector with minimal Harbinger glue code;
- it gives the reader intuition about anomalies as local temporal disruptions, not only as large residuals from a forecasting model.

## Method at a glance

The custom detector converts the input into a time-series object and applies `forecast::tsoutliers()`. The returned outlier positions are then mapped to Harbinger's standard detection table. In other words, the external library decides which timestamps look suspicious, and Harbinger standardizes the result for plotting and evaluation.

The integration contract is intentionally small. We define a constructor based on `harbinger()`, store the configuration in the object, implement the `detect()` method, and then reuse the usual plotting and evaluation steps.

To make the example concrete, the custom detector wraps `forecast::tsoutliers()`, a classical routine for identifying additive outliers in univariate time series.






### Prepare the Example

This setup anchors the notebook in the specific series used to examine `forecast::tsoutliers()`. The semantic point is the one stated above: the custom detector converts the input into a time-series object and applies `forecast::tsoutliers()`, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


``` r
# installation
# install.packages(c("harbinger", "daltoolbox", "forecast"))

library(daltoolbox)
library(harbinger)
```





### Define the Support Structures

The code below defines the smallest Harbinger contract needed to express the idea behind this example. Read it in semantic terms: the goal is to encode that the custom detector converts the input into a time-series object and applies `forecast::tsoutliers()` while still returning objects that Harbinger can plot and evaluate like any native method.


``` r
hanr_tsoutliers_custom <- function(frequency = 1) {
  obj <- harbinger()
  obj$frequency <- frequency
  class(obj) <- append("hanr_tsoutliers_custom", class(obj))
  obj
}

detect.hanr_tsoutliers_custom <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  y_ts <- stats::ts(obj$serie, frequency = obj$frequency)
  out <- forecast::tsoutliers(y_ts)

  anomalies <- rep(FALSE, length(obj$serie))
  if (!is.null(out$index) && length(out$index) > 0) {
    anomalies[unique(out$index)] <- TRUE
  }

  obj$har_restore_refs(obj, anomalies = anomalies)
}
```

We now use the custom detector exactly as we would use any other anomaly detector in the package.





### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `forecast::tsoutliers()`, the important question is whether the resulting anomaly flags really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
data(examples_anomalies)
dataset <- examples_anomalies$simple

model <- hanr_tsoutliers_custom()
detection <- detect(model, dataset$serie)
```





### Evaluate What Was Found

The evaluation asks whether the anomaly flags produced by `forecast::tsoutliers()` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     0    
## FALSE     1     100
```





### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted anomaly flags line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/02-anomaly-custom_anomaly/unnamed-chunk-5-1.png)

This example shows that a custom anomaly detector does not need to reimplement the whole Harbinger workflow. It only needs to respect the expected constructor-plus-detection contract.

## References

- Hyndman, R. J., Athanasopoulos, G. (2021). Forecasting: Principles and Practice.
