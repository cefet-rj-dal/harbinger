# Time Series Global Min-Max

Rescales data, so the minimum value is mapped to 0 and the maximum value
is mapped to 1.

## Usage

``` r
ts_gminmax(remove_outliers = TRUE)
```

## Arguments

- remove_outliers:

  logical: if TRUE (default) outliers will be removed.

## Value

a `ts_gminmax` object.
