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



## Walkthrough



### Prepare the Example

We begin by organizing the environment, loading the packages, and selecting the dataset used in the notebook. This part is intentionally more direct: the goal is to make the starting point explicit before the method-specific reasoning begins.


``` r
# installation
# install.packages(c("harbinger", "daltoolbox", "forecast"))

library(daltoolbox)
library(harbinger)
```





### Define the Support Structures

Before applying the workflow itself, we define the helper functions or custom objects that make the example possible. This is one of the most important didactic moments in extension-oriented notebooks because it shows the contract that Harbinger expects and where the reader can adapt the behavior later.


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

With the environment and the method ready, we execute the central analytical step and inspect its immediate output. This is the point where the abstract idea described earlier becomes operational, so the reader should pay attention to what is produced and how Harbinger standardizes the result.


``` r
data(examples_anomalies)
dataset <- examples_anomalies$simple

model <- hanr_tsoutliers_custom()
detection <- detect(model, dataset$serie)
```





### Evaluate What Was Found

After producing detections or transformed outputs, we compare them with the reference labels whenever they are available. This stage matters because it connects the visual intuition of the method with an explicit measurement of quality, helping the learner understand not only whether the method runs, but how well it behaves.


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

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/02-anomaly-custom_anomaly/unnamed-chunk-5-1.png)

This example shows that a custom anomaly detector does not need to reimplement the whole Harbinger workflow. It only needs to respect the expected constructor-plus-detection contract.

## References

- Hyndman, R. J., Athanasopoulos, G. (2021). Forecasting: Principles and Practice.
