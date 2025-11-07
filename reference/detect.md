# Detect events in time series

Generic S3 generic for event detection using a fitted Harbinger model.
Concrete methods are implemented by each detector class.

## Usage

``` r
detect(obj, ...)
```

## Arguments

- obj:

  A `harbinger` detector object.

- ...:

  Additional arguments passed to methods.

## Value

A data frame with columns: `idx` (index), `event` (logical), and `type`
(character: "anomaly", "changepoint", or ""). Some detectors may also
attach attributes (e.g., `threshold`) or columns (e.g., `seq`,
`seqlen`).

## Examples

``` r
# See detector-specific examples in the package site for usage patterns
# and plotting helpers.
```
