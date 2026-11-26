# Stream collector (extension seam for live brokers)

Abstract pull collector that yields one observation at a time. This is
the extension point for live streams: provide a collector whose
`get_next()` returns a single observation (scalar, one-row data.frame,
or a list with at least a `value` field) or `NULL` when the stream is
exhausted, and an optional
[`close()`](https://rdrr.io/r/base/connections.html). Harbinger ships
*no* broker dependency; a real Kafka collector is user-supplied code
backed by the user's own client (e.g. via `reticulate`).

## Usage

``` r
har_stream_collector()
```

## Value

A `har_stream_collector` object whose `get_next()` must be overridden.

## Examples

``` r
collector <- har_stream_collector()
try(collector$get_next())
#> Error : get_next() must be implemented by the collector.
```
