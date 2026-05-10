# Anomaly detector based on machine learning classification

Takes as input a "Harbinger" object and a time series

## Usage

``` r
# S3 method for hanc_ml
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
