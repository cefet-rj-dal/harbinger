# Collect the online trace

Returns one row per observed time point with the quantities needed to
compute Detection Probability (DP) and Detection Lag (DL).

## Usage

``` r
collect_trace(obj)
```

## Arguments

- obj:

  Online session.

## Value

Data frame with one row per observation and columns:

- `idx`

- `timestamp`

- `batch_id_first_seen`

- `batch_frequency`

- `detection_frequency`

- `first_detected_batch`

- `last_detected_batch`

- `detection_probability`

- `detection_lag_batches`

- `detection_lag_observations`

- `event_type`
