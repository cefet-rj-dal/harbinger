# Data-frame source

Convenience wrapper around
[`har_source_simulated()`](https://cefet-rj-dal.github.io/harbinger/reference/har_source_simulated.md)
for table-shaped inputs.

## Usage

``` r
har_source_dataframe(
  data,
  timestamp_col = NULL,
  value_cols = NULL,
  name = "dataframe"
)
```

## Arguments

- data:

  Data frame in time order.

- timestamp_col:

  Optional timestamp column name or position.

- value_cols:

  Optional value columns. Defaults to all columns except the timestamp
  column when provided.

- name:

  Source name.

## Value

A `har_source_dataframe` object.

## Examples

``` r
df <- data.frame(ts = 1:3, value = c(10, 11, 9))
source <- har_source_dataframe(df, timestamp_col = "ts", value_cols = "value")
obs <- next_observation(source)
obs$observation$timestamp
#> [1] 1
```
