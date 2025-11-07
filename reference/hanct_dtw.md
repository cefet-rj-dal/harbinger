# Anomaly detector using DTW

Anomaly detection using DTW The DTW is applied to the time series. When
seq equals one, observations distant from the closest centroids are
labeled as anomalies. When seq is grater than one, sequences distant
from the closest centroids are labeled as discords. It wraps the tsclust
presented in the dtwclust library.

## Usage

``` r
hanct_dtw(seq = 1, centers = NA)
```

## Arguments

- seq:

  sequence size

- centers:

  number of centroids

## Value

`hanct_dtw` object

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

# Configure DTW-based detector
model <- hanct_dtw()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected events
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
