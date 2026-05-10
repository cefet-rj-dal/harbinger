# Anomaly detector using GARCH

Fits a GARCH model to capture conditional heteroskedasticity and flags
observations with large standardized residuals as anomalies. Wraps
`rugarch`.

## Usage

``` r
hanr_garch()
```

## Value

`hanr_garch` object.

## Details

A sGARCH(1,1) with ARMA(1,1) mean is estimated. Standardized residuals
are summarized and thresholded via
[`harutils()`](https://cefet-rj-dal.github.io/harbinger/reference/harutils.md).

## References

- Engle RF (1982). Autoregressive Conditional Heteroscedasticity with
  Estimates of the Variance of United Kingdom Inflation. Econometrica,
  50(4):987–1007.

- Bollerslev T (1986). Generalized Autoregressive Conditional
  Heteroskedasticity. Journal of Econometrics, 31(3):307–327.

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

# Configure GARCH anomaly detector
model <- hanr_garch()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
