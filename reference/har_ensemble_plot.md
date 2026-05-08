# Plot Harbinger Ensemble Outputs

Visualize ensemble detection results and the individual model votes
stored by
[`har_ensemble_fuzzy()`](https://cefet-rj-dal.github.io/harbinger/reference/har_ensemble_fuzzy.md).

The plotting helpers do not recompute detections. They use the
attributes attached to the detection object as the source of truth.

## Usage

``` r
har_ensemble_plot(detection, serie, threshold = NULL, time_idx = NULL)
```

## Arguments

- detection:

  A detection object returned by `detect.har_ensemble_fuzzy`.

- serie:

  Numeric vector with the original time series.

- threshold:

  Optional threshold override for the score panel.

- time_idx:

  Optional x-axis vector.

## Value

A `patchwork` object.
