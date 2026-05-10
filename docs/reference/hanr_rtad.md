# Resilient Transformation Anomaly Detector (RTAD)

Hybrid anomaly detector built from the Resilient Transformation (RT)
proposed in the RT/RTAD paper. The series is decomposed with CEEMD, the
highest-frequency structure is selected from IMF roughness, the
transformed signal is differentiated, and local dispersion is used to
normalize deviations before thresholding.

RTAD is not a generic wrapper around EMD. It is the standalone detector
obtained when the resilient transformation is coupled with a simple
decision rule.

## Usage

``` r
hanr_rtad(sw_size = 30, noise = 0.001, trials = 5, sigma = sd)
```

## Arguments

- sw_size:

  Sliding window size used to compute local dispersion.

- noise:

  CEEMD noise amplitude.

- trials:

  Number of CEEMD trials.

- sigma:

  Function used to compute local dispersion.

## Value

`hanr_rtad` object

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## Examples

``` r
library(daltoolbox)
library(zoo)
#> Warning: package 'zoo' was built under R version 4.5.2
#> 
#> Attaching package: 'zoo'
#> The following objects are masked from 'package:base':
#> 
#>     as.Date, as.Date.numeric

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

# Configure RTAD detector
model <- hanr_rtad()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected events
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
