# Anomaly detector using histograms

Flags observations that fall into low-density histogram bins or outside
the observed bin range.

## Usage

``` r
hanr_histogram(density_threshold = 0.05)
```

## Arguments

- density_threshold:

  Numeric between 0 and 1. Minimum bin density to avoid being considered
  an anomaly (default 0.05).

## Value

`hanr_histogram` object

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

# Configure histogram-based detector
model <- hanr_histogram()

# Fit the model (no-op)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 1    1  TRUE anomaly
#> 50  50  TRUE anomaly
```
