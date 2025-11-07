# Anomaly detector using autoencoders

Trains an encoder-decoder (autoencoder) to reconstruct sliding windows
of the series; large reconstruction errors indicate anomalies.

## Usage

``` r
han_autoencoder(input_size, encode_size, encoderclass = autoenc_base_ed, ...)
```

## Arguments

- input_size:

  Integer. Input (and output) window size for the autoencoder.

- encode_size:

  Integer. Size of the encoded (bottleneck) representation.

- encoderclass:

  DALToolbox encoder-decoder constructor to instantiate.

- ...:

  Additional arguments forwarded to `encoderclass`.

## Value

`han_autoencoder` object

## References

- Sakurada M, Yairi T (2014). Anomaly Detection Using Autoencoders with
  Nonlinear Dimensionality Reduction. MLSDA 2014.

## Examples

``` r
library(daltoolbox)
#> 
#> Attaching package: ‘daltoolbox’
#> The following object is masked from ‘package:base’:
#> 
#>     transform
library(tspredit)

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

# Configure an autoencoder-based anomaly detector
model <- han_autoencoder(input_size = 5, encode_size = 3)

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Inspect detected anomalies
print(detection[detection$event, ])
#> [1] idx   event type 
#> <0 rows> (or 0-length row.names)
```
