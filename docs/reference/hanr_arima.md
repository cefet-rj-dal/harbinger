# Anomaly detector using ARIMA

Fits an ARIMA model to the series and flags observations with large
model residuals as anomalies. Wraps ARIMA from the `forecast` package.

## Usage

``` r
hanr_arima()
```

## Value

`hanr_arima` object.

## Details

The detector estimates ARIMA(p,d,q) and computes standardized residuals.
Residual magnitudes are summarized via a distance function and
thresholded with outlier heuristics from
[`harutils()`](https://cefet-rj-dal.github.io/harbinger/reference/harutils.md).

## References

- Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series
  Analysis: Forecasting and Control. Wiley.

## Examples

``` r
library(daltoolbox)

# Load anomaly example data
data(examples_anomalies)

# Use a simple example
dataset <- examples_anomalies$simple
head(dataset)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9689124 FALSE
#> 3 0.8775826 FALSE
#> 4 0.7316889 FALSE
#> 5 0.5403023 FALSE
#> 6 0.3153224 FALSE

# Configure ARIMA anomaly detector
model <- hanr_arima()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
