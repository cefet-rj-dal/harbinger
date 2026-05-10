# Anomaly Detector using FFT with AMOC and CUSUM Cutoff

This detector combines FFT-based spectral filtering with an AMOC
change-point cutoff applied to the cumulative spectrum. The
lower-frequency components are removed, the signal is reconstructed, and
the residual is scored for anomalies.

This function extends the HARBINGER framework and returns an object of
class `hanr_fft_amoc_cusum`.

## Usage

``` r
hanr_fft_amoc_cusum()
```

## Value

`hanr_fft_amoc_cusum` object

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

# Configure FFT+CUSUM+AMOC detector
model <- hanr_fft_amoc_cusum()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Inspect detected anomalies
print(detection[detection$event, ])
#>    idx event    type
#> 50  50  TRUE anomaly
```
