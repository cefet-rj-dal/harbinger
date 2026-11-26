# Simulated stream collector

Reference collector that replays an in-memory vector, matrix, or data
frame one observation at a time. It lets a
[`har_source_kafka()`](https://cefet-rj-dal.github.io/harbinger/reference/har_source_kafka.md)
run end-to-end without a broker, and is the template for a real-broker
collector.

## Usage

``` r
har_simulated_collector(data)
```

## Arguments

- data:

  Numeric vector, matrix, or data frame in time order.

## Value

A `har_simulated_collector` object exposing
`get_next()`/[`close()`](https://rdrr.io/r/base/connections.html).

## Examples

``` r
collector <- har_simulated_collector(c(10, 11, 12))
collector$get_next()
#> [1] 10
collector$get_next()
#> [1] 11
```
