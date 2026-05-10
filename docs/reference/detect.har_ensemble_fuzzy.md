# Detect events using Harbinger Fuzzy Ensemble

Detect events using Harbinger Fuzzy Ensemble

## Usage

``` r
# S3 method for class 'har_ensemble_fuzzy'
detect(
  obj,
  serie,
  threshold = NULL,
  threshold_type = NULL,
  time_tolerance = NULL,
  use_nms = NULL,
  outliers_check = NULL,
  outlier_filter = NULL,
  ...
)
```

## Arguments

- obj:

  A `har_ensemble_fuzzy` object.

- serie:

  Input time series.

- threshold:

  Numeric detection threshold.

- threshold_type:

  Either `"fixed"` or `"percentile"`.

- time_tolerance:

  Integer window for temporal fuzzification and NMS.

- use_nms:

  Logical; whether to apply non-maximum suppression.

- outliers_check:

  Optional refinement function.

- outlier_filter:

  Optional post-filter over the ensemble score. It may return a logical
  mask or integer positions.

- ...:

  Additional arguments.

## Value

A detection object with score and per-model events as attributes.
