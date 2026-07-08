# Detect-only execution strategy

Uses the detector as already fitted and only calls
[`detect()`](https://cefet-rj-dal.github.io/harbinger/reference/detect.md)
during the online loop. This is useful when the model is pre-trained or
when warm-up fitting should happen only once.

## Usage

``` r
har_online_detect_only(fit_on_warmup = FALSE)
```

## Arguments

- fit_on_warmup:

  Whether the detector should be fitted once after warm-up.

## Value

A `har_online_detect_only` object.

## Examples

``` r
exec <- har_online_detect_only()
exec$fit_each_run
#> [1] FALSE
```
