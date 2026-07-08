# Collect final detection output

Materializes the final detection table from the online session trace.

## Usage

``` r
collect_detection(obj)
```

## Arguments

- obj:

  Online session.

## Value

A data frame with the usual `idx`, `event`, and `type` columns plus
online summary columns:

- `detection_probability`

- `detection_lag_batches`

- `detection_lag_observations`
