# Anomaly detector using FFT

High-pass filtering via FFT to isolate high-frequency components;
anomalies are flagged where the filtered magnitude departs strongly from
baseline.

## Usage

``` r
hanr_fft()
```

## Value

`hanr_fft` object

## Details

The spectrum is computed by FFT, a cutoff is selected from the power
spectrum, low frequencies are nulled, and the inverse FFT reconstructs a
high-pass signal. Magnitudes are summarized and thresholded using
[`harutils()`](https://cefet-rj-dal.github.io/harbinger/reference/harutils.md).

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

# Configure FFT-based anomaly detector
model <- hanr_fft()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
