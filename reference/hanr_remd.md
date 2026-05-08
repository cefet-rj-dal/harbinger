# Anomaly detector using REMD

Anomaly detection using REMD with EMD-based decomposition. The detector
decomposes the series, selects components according to curvature, and
flags large residual deviations as anomalies. Wraps the EMD-based model
presented in the `forecast` package.

## Usage

``` r
hanr_remd(noise = 0.1, trials = 5)
```

## Arguments

- noise:

  Noise amplitude for the decomposition.

- trials:

  Number of trials used by the decomposition step.

## Value

`hanr_remd` object

## References

- Souza, J., Paixão, E., Fraga, F., Baroni, L., Alves, R. F. S.,
  Belloze, K., Dos Santos, J., Bezerra, E., Porto, F., Ogasawara, E.
  REMD: A Novel Hybrid Anomaly Detection Method Based on EMD and ARIMA.
  Proceedings of the International Joint Conference on Neural
  Networks, 2024. doi:10.1109/IJCNN60899.2024.10651192

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

# Configure REMD detector
model <- hanr_remd()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
#> 54  54  TRUE anomaly
```
