# Plot individual model detections in a Harbinger fuzzy ensemble

Visualizes the original series and the per-model detections stored in
the `model_events` attribute returned by
[`detect.har_ensemble_fuzzy()`](https://cefet-rj-dal.github.io/harbinger/reference/detect.har_ensemble_fuzzy.md).

## Usage

``` r
har_ensemble_plot_models(detection, serie, time_idx = NULL)
```

## Arguments

- detection:

  A detection object returned by `detect.har_ensemble_fuzzy`.

- serie:

  Numeric vector with the original time series.

- time_idx:

  Optional x-axis vector.

## Value

A `patchwork` object.
