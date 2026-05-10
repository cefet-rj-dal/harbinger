# Time Series Adaptive Normalization

Transform data to a common scale while taking into account the changes
in the statistical properties of the data over time.

## Usage

``` r
ts_an(remove_outliers = TRUE, nw = 0)
```

## Arguments

- remove_outliers:

  logical: if TRUE (default) outliers will be removed.

- nw:

  integer: .

## Value

a `ts_an` object.
