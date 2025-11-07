# Anomaly detector using EMD

Empirical Mode Decomposition (CEEMD) to extract intrinsic mode functions
and flag anomalies from high-frequency components. Wraps
[`hht::CEEMD`](https://rdrr.io/pkg/hht/man/CEEMD.html).

## Usage

``` r
hanr_emd(noise = 0.1, trials = 5)
```

## Arguments

- noise:

  Numeric. Noise amplitude for CEEMD.

- trials:

  Integer. Number of CEEMD trials.

## Value

`hanr_emd` object

## References

- Huang NE, et al. (1998). The empirical mode decomposition and the
  Hilbert spectrum for nonlinear and non-stationary time series
  analysis. Proc. Royal Society A.

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

# Configure EMD-based anomaly detector
model <- hanr_emd()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomalies
print(detection[(detection$event),])
#>    idx event    type
#> 49  49  TRUE anomaly
```
