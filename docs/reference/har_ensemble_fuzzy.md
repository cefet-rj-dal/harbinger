# Harbinger Fuzzy Ensemble

Score-based ensemble across multiple Harbinger detectors with optional
temporal fuzzification, thresholding, and non-maximum suppression.

This variant preserves the richer aggregation logic that was previously
mixed into
[`har_ensemble()`](https://cefet-rj-dal.github.io/harbinger/reference/har_ensemble.md),
but keeps the simple majority-vote ensemble separate.

## Usage

``` r
har_ensemble_fuzzy(...)
```

## Arguments

- ...:

  One or more detector objects.

## Value

A `har_ensemble_fuzzy` object.

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## Examples

``` r
library(daltoolbox)

data(examples_changepoints)
dataset <- examples_changepoints$simple

model <- har_ensemble_fuzzy(hcp_amoc(), hcp_pelt(), hcp_cf_lr())
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie, time_tolerance = 8, use_nms = TRUE)
print(detection[detection$event, ])
#>    idx event type
#> 81  81  TRUE     
```
