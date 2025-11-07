# Anomaly Detector using Adaptive FFT and Moving Average

This function implements an anomaly detection model based on the Fast
Fourier daltoolbox::transform (FFT), combined with an adaptive moving
average filter. The method estimates the dominant frequency in the input
time series using spectral analysis and then applies a moving average
filter with a window size derived from that frequency. This highlights
high-frequency deviations, which are likely to be anomalies.

The residuals (original signal minus smoothed version) are then
processed to compute the distance from the expected behavior, and points
significantly distant are flagged as anomalies. The detection also
includes a grouping strategy to reduce false positives by selecting the
most representative point in a cluster of consecutive anomalies.

This function extends the HARBINGER framework and returns an object of
class `hanr_fft_sma`.

## Usage

``` r
hanr_fft_sma()
```

## Value

`hanr_fft_sma` object

## References

- Sobrinho, E. P., Souza, J., Lima, J., Giusti, L., Bezerra, E.,
  Coutinho, R., Baroni, L., Pacitti, E., Porto, F., Belloze, K.,
  Ogasawara, E. Fine-Tuning Detection Criteria for Enhancing Anomaly
  Detection in Time Series. In: Simpósio Brasileiro de Banco de Dados
  (SBBD). SBC, 29 Sep. 2025. doi:10.5753/sbbd.2025.247063

## Examples

``` r
library(daltoolbox)

# Load anomaly example data
data(examples_anomalies)

#Using simple example
dataset <- examples_anomalies$simple
head(dataset)
#>       serie event
#> 1 1.0000000 FALSE
#> 2 0.9689124 FALSE
#> 3 0.8775826 FALSE
#> 4 0.7316889 FALSE
#> 5 0.5403023 FALSE
#> 6 0.3153224 FALSE

# setting up time series fft detector
model <- hanr_fft_sma()

# fitting the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)
#> Warning: longer object length is not a multiple of shorter object length

# filtering detected events
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
