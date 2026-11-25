# Anomaly detector using ARIMA (ARIMA++)

Fits an ARIMA model to the series and flags observations with large
model residuals as anomalies.

## Usage

``` r
hanr_arima(auto = "aicc", max_order = 12, cv_folds = 2, horizon = NULL)
```

## Arguments

- auto:

  Order selector forwarded to
  [`tspredit::fit_arima()`](https://rdrr.io/pkg/tspredit/man/fit_arima.html):
  `"aicc"` (default, compact AICc search) or `"cv"` (the heavier ARIMA++
  rolling-origin cross-validated selector, tuned for forecasting).

- max_order:

  Cap for the ACF/PACF-driven candidate lags (ARIMA++ `"cv"`).

- cv_folds:

  Number of rolling origins for the CV selection (ARIMA++ `"cv"`).

- horizon:

  CV horizon (ARIMA++ `"cv"`); `NULL` -\> the detected seasonal period.

## Value

`hanr_arima` object.

## Details

This is the backport of the Python `pyharbinger::HanrArima` releitura.
Instead of
[`forecast::auto.arima`](https://pkg.robjhyndman.com/forecast/reference/auto.arima.html),
the ARIMA order is selected by the DAL ARIMA auto-selector
[`tspredit::fit_arima()`](https://rdrr.io/pkg/tspredit/man/fit_arima.html)
– the native (base [`stats::arima`](https://rdrr.io/r/stats/arima.html))
replacement for `auto.arima` – so `harbinger` no longer depends on the
`forecast` package. `auto = "aicc"` (default) is a compact AICc search;
the detector flags points whose in-sample ARIMA residual is unusually
large.

The first `sw_size = max(p, d + 1, q)` residuals are a warm-up window:
they are neutralised **before** the outlier statistics (not only masked
afterwards), so a large initialisation transient cannot inflate the
threshold and hide the real anomalies. Residual magnitudes are
summarised via a distance function and thresholded with the outlier
heuristics from
[`harutils()`](https://cefet-rj-dal.github.io/harbinger/reference/harutils.md).

## References

- Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series
  Analysis: Forecasting and Control. Wiley.

- Hyndman RJ, Khandakar Y (2008). Automatic time series forecasting: the
  forecast package for R. Journal of Statistical Software, 27(3).
  doi:10.18637/jss.v027.i03

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
