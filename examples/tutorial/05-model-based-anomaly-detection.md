## Tutorial 05 - Model-Based Anomaly Detection

After a simple baseline, the next step is to model the expected behavior of the series and look for unusual residuals. `hanr_arima()` follows exactly that idea: fit an ARIMA model, compute residuals, and flag large deviations.

This notebook is useful because it connects anomaly detection with a standard time-series modeling workflow.

The technique is residual-based anomaly detection. ARIMA tries to explain the normal temporal structure of the signal, and anomalies appear as points where the observed value deviates too much from what the fitted model would expect.

Load the packages and the example series.

``` r
library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
```

Configure the ARIMA-based detector and fit it to the series.

``` r
model <- hanr_arima()
model <- fit(model, dataset$serie)
```

Run detection and inspect the returned events.

``` r
detection <- detect(model, dataset$serie)
head(detection)
```

```
##   idx event type
## 1   1 FALSE     
## 2   2 FALSE     
## 3   3 FALSE     
## 4   4 FALSE     
## 5   5 FALSE     
## 6   6 FALSE
```

Evaluate the detections against the labels.

``` r
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```

Plot the detections on the original series.

``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/05-model-based-anomaly-detection/unnamed-chunk-5-1.png)

The residual signal helps explain why points were flagged.

``` r
har_plot(
  model,
  attr(detection, "res"),
  detection,
  dataset$event,
  yline = attr(detection, "threshold")
)
```

![plot of chunk unnamed-chunk-6](fig/05-model-based-anomaly-detection/unnamed-chunk-6-1.png)

## References

- Box, G. E. P., Jenkins, G. M., Reinsel, G. C., Ljung, G. M. (2015). Time Series Analysis: Forecasting and Control. Wiley.
