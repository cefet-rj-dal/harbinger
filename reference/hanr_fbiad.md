# Anomaly detector using FBIAD

Anomaly detector using FBIAD

## Usage

``` r
hanr_fbiad(sw_size = 30)
```

## Arguments

- sw_size:

  Window size for FBIAD

## Value

hanr_fbiad object Forward and Backward Inertial Anomaly Detector (FBIAD)
detects anomalies in time series. Anomalies are observations that differ
from both forward and backward time series inertia
<doi:10.1109/IJCNN55064.2022.9892088>.

## References

- Lima, J., Salles, R., Porto, F., Coutinho, R., Alpis, P., Escobar, L.,
  Pacitti, E., Ogasawara, E. Forward and Backward Inertial Anomaly
  Detector: A Novel Time Series Event Detection Method. Proceedings of
  the International Joint Conference on Neural Networks, 2022.
  doi:10.1109/IJCNN55064.2022.9892088

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

# Configure FBIAD detector
model <- hanr_fbiad()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
