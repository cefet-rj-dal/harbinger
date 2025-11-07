# Anomaly Detector using FFT with AMOC and CUSUM Cutoff

This function implements an anomaly detection method based on the Fast
Fourier daltoolbox::transform (FFT) and a changepoint-based cutoff
strategy using the AMOC (At Most One Change) algorithm applied to the
cumulative sum (CUSUM) of the power spectrum.

The method first computes the FFT of the input time series and extracts
the power spectrum. It then applies a CUSUM transformation to the
spectral data to emphasize gradual changes or shifts in spectral energy.
Using the AMOC algorithm, it detects a single changepoint in the
CUSUM-transformed spectrum, which serves as a cutoff index to remove the
lower-frequency components.

The remaining high-frequency components are then reconstructed into a
time-domain signal via inverse FFT, effectively isolating rapid or local
deviations. Anomalies are detected by evaluating the distance between
this filtered signal and the original series, highlighting points that
deviate significantly from the expected pattern.

This method is suitable for series where spectral shifts are subtle and
a single significant change in behavior is expected.

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
