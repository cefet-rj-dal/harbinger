# Performs anomaly event detection in the time series using the GARCH model

Takes as input a "Harbinger" object and a time series

## Usage

``` r
# S3 method for hanr_garch
detect(obj, serie, ...)
```

## Arguments

- obj:

  detector

- serie:

  time series

- ...:

  optional arguments.

## Value

A dataframe with information about the detected anomalous points
