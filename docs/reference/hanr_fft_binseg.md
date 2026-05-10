# Anomaly Detector using FFT with Binary Segmentation Cutoff

This detector combines FFT-based spectral filtering with a Binary
Segmentation change-point cutoff on the power spectrum. Frequencies
below the selected cutoff are removed, the signal is reconstructed from
the remaining high-frequency content, and the residual is scored for
anomalies.

This function is part of the HARBINGER framework and returns an object
of class `hanr_fft_binseg`.

## Usage

``` r
hanr_fft_binseg()
```

## Value

`hanr_fft_binseg` object

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

# Configure FFT+BinSeg detector
model <- hanr_fft_binseg()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Inspect detected anomalies
print(detection[detection$event, ])
#>    idx event    type
#> 50  50  TRUE anomaly

```
