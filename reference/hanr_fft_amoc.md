# Anomaly Detector using FFT with AMOC Cutoff

This function implements an anomaly detection method that uses the Fast
Fourier daltoolbox::transform (FFT) combined with an automatic frequency
cutoff strategy based on the AMOC (At Most One Change) algorithm. The
model analyzes the power spectrum of the time series and detects the
optimal cutoff frequency — the point where the frequency content
significantly changes — using a changepoint detection method from the
`changepoint` package.

All frequencies below the cutoff are removed from the spectrum, and the
inverse FFT reconstructs a filtered version of the original signal that
preserves only high-frequency components. The resulting residual signal
is then analyzed to identify anomalous patterns based on its distance
from the expected behavior.

This function extends the HARBINGER framework and returns an object of
class `hanr_fft_amoc`.

## Usage

``` r
hanr_fft_amoc()
```

## Value

`hanr_fft_amoc` object

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

# Configure FFT+AMOC detector
model <- hanr_fft_amoc()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Inspect detected anomalies
print(detection[detection$event, ])
#>    idx event    type
#> 50  50  TRUE anomaly
```
