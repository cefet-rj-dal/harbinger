# Collect batch execution log

Returns one row per completed online detection cycle.

## Usage

``` r
collect_batch_log(obj)
```

## Arguments

- obj:

  Online session.

## Value

Data frame with one row per batch and columns:

- `batch_id`

- `memory_size`

- `fit_time_sec`

- `detect_time_sec`

- `total_time_sec`
