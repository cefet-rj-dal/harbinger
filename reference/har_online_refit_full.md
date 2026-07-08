# Full refit execution strategy

Re-fits the detector on the current in-memory series before each batch
detection.

## Usage

``` r
har_online_refit_full(fit_on_warmup = TRUE)
```

## Arguments

- fit_on_warmup:

  Whether the detector should be fitted once after warm-up.

## Value

A `har_online_refit_full` object.

## Examples

``` r
exec <- har_online_refit_full()
exec$mode
#> [1] "refit_full"
```
