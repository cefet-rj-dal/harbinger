# Anomaly detector using REMD

Anomaly detection using REMD The EMD model adjusts to the time series.
Observations distant from the model are labeled as anomalies. It wraps
the EMD model presented in the forecast library.

## Usage

``` r
hanr_remd(noise = 0.1, trials = 5)
```

## Arguments

- noise:

  nosie

- trials:

  trials

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
#> 51  51  TRUE anomaly
#> 53  53  TRUE anomaly
```
