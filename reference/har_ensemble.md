# Harbinger Ensemble

Majority-vote ensemble across multiple Harbinger detectors with optional
temporal fuzzification to combine nearby detections.

## Usage

``` r
har_ensemble(...)
```

## Arguments

- ...:

  One or more detector objects.

## Value

A `har_ensemble` object

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

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

# Configure an ensemble of detectors
model <- har_ensemble(hanr_arima(), hanr_arima(), hanr_arima())
# model <- har_ensemble(hanr_fbiad(), hanr_arima(), hanr_emd())

# Fit all ensemble members
model <- fit(model, dataset$serie)

# Run ensemble detection
detection <- detect(model, dataset$serie)

# Show detected events
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
