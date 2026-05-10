# Detect anomalies in time series using ARIMA models

Takes as input a "Harbinger" object and a time series

## Usage

``` r
# S3 method for hanr_arima
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

## Examples

``` r
detector <- harbinger()
```
