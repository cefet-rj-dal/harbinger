# Evaluation of event detection

Hard evaluation of event detection producing confusion matrix and common
metrics (accuracy, precision, recall, F1, etc.).

## Usage

``` r
har_eval()
```

## Value

`har_eval` object

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

# Evaluate detections
evaluation <- evaluate(har_eval(), detection$event, dataset$event)
print(evaluation$confMatrix)
#>           event      
#> detection TRUE  FALSE
#> TRUE      0     1    
#> FALSE     1     99   

# Plot the results
grf <- har_plot(model, dataset$serie, detection, dataset$event)
#> Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
#> ℹ Please use `linewidth` instead.
#> ℹ The deprecated feature was likely used in the harbinger package.
#>   Please report the issue at
#>   <https://github.com/cefet-rj-dal/harbinger/issues>.
plot(grf)

```
