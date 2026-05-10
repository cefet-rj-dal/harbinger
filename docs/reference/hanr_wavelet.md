# Anomaly detector using Wavelets

Multiresolution decomposition via wavelets; anomalies are flagged where
aggregated wavelet detail coefficients indicate unusual energy.

## Usage

``` r
hanr_wavelet(filter = "haar")
```

## Arguments

- filter:

  Character. Available wavelet filters: `haar`, `d4`, `la8`, `bl14`,
  `c6`.

## Value

`hanr_wavelet` object

## Details

The series is decomposed with MODWT and detail bands are aggregated to
compute a magnitude signal that is thresholded using
[`harutils()`](https://cefet-rj-dal.github.io/harbinger/reference/harutils.md).

## References

- Mallat S (1989). A theory for multiresolution signal decomposition:
  The wavelet representation. IEEE Transactions on Pattern Analysis and
  Machine Intelligence, 11(7):674–693.

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

# Configure wavelet-based anomaly detector
model <- hanr_wavelet()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 50  50  TRUE anomaly
```
