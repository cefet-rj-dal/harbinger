# Incremental execution strategy

Placeholder strategy for detectors with native stateful updates. When a
detector exposes an `online_update()` function in the detector object,
the session will call it before detection. Otherwise the strategy falls
back to detect-only behavior.

## Usage

``` r
har_online_incremental(fit_on_warmup = TRUE)
```

## Arguments

- fit_on_warmup:

  Whether the detector should be fitted once after warm-up.

## Value

A `har_online_incremental` object.

## Examples

``` r
exec <- har_online_incremental()
exec$mode
#> [1] "incremental"
```
