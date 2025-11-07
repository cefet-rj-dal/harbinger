# Anomaly detector based on ML regression

Trains a regression model to forecast the next value from a sliding
window and flags large prediction errors as anomalies. Uses DALToolbox
regressors.

A set of preconfigured regression methods are described at
<https://cefet-rj-dal.github.io/daltoolbox/> (e.g., `ts_elm`,
`ts_conv1d`, `ts_lstm`, `ts_mlp`, `ts_rf`, `ts_svm`).

## Usage

``` r
hanr_ml(model, sw_size = 15)
```

## Arguments

- model:

  A DALToolbox regression model.

- sw_size:

  Integer. Sliding window size.

## Value

`hanr_ml` object.

## References

- Hyndman RJ, Athanasopoulos G (2021). Forecasting: Principles and
  Practice. OTexts.

- Goodfellow I, Bengio Y, Courville A (2016). Deep Learning. MIT Press.

## Examples

``` r
library(daltoolbox)
library(tspredit)

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

# Configure a time series regression model
model <- hanr_ml(tspredit::ts_elm(tspredit::ts_norm_gminmax(),
                   input_size=4, nhid=3, actfun="purelin"))

# Fit the model
model <- daltoolbox::fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 52  52  TRUE anomaly
```
