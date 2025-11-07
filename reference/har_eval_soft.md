# Evaluation of event detection (SoftED)

Soft evaluation of event detection using SoftED
<doi:10.48550/arXiv.2304.00439>.

## Usage

``` r
har_eval_soft(sw_size = 15)
```

## Arguments

- sw_size:

  Integer. Tolerance window size for soft matching.

## Value

`har_eval_soft` object

## References

- Salles, R., Lima, J., Reis, M., Coutinho, R., Pacitti, E., Masseglia,
  F., Akbarinia, R., Chen, C., Garibaldi, J., Porto, F., Ogasawara, E.
  SoftED: Metrics for soft evaluation of time series event detection.
  Computers and Industrial Engineering, 2024.
  doi:10.1016/j.cie.2024.110728

## Examples

``` r
library(daltoolbox)

# Load anomaly example data
data(examples_anomalies)

# Use the simple series
dataset <- examples_anomalies$simple
head(dataset)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9689124 FALSE
#> 3 0.8775826 FALSE
#> 4 0.7316889 FALSE
#> 5 0.5403023 FALSE
#> 6 0.3153224 FALSE

# Configure a change-point detector (GARCH)
model <- hcp_garch()

# Fit the detector
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected events
print(detection[(detection$event),])
#>    idx event        type
#> 52  52  TRUE changepoint

# Evaluate detections (SoftED)
evaluation <- evaluate(har_eval_soft(), detection$event, dataset$event)
print(evaluation$confMatrix)
#>           event      
#> detection TRUE  FALSE
#> TRUE      0.87  0.13 
#> FALSE     0.13  99.87

# Plot the results
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)

```
