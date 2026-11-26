# Kafka source (dependency-free streaming abstraction)

Kafka-shaped source that holds the broker configuration but delegates
the actual consumption to a pluggable `collector` exposing `get_next()`.
Harbinger declares **no** Kafka dependency: attach a
[`har_simulated_collector()`](https://cefet-rj-dal.github.io/harbinger/reference/har_simulated_collector.md)
to test end-to-end, or your own collector backed by a real Kafka client
(e.g. a `reticulate` Python consumer) to read a live topic. The
collector is pulled one observation at a time, modelling true streaming.

## Usage

``` r
har_source_kafka(
  topic,
  bootstrap_servers,
  group_id,
  collector = NULL,
  value_schema = NULL,
  name = "kafka"
)
```

## Arguments

- topic:

  Kafka topic name.

- bootstrap_servers:

  Character vector with broker addresses.

- group_id:

  Consumer group identifier.

- collector:

  Optional collector object exposing `get_next()` (and an optional
  [`close()`](https://rdrr.io/r/base/connections.html)). Without one the
  source raises on
  [`next_observation()`](https://cefet-rj-dal.github.io/harbinger/reference/next_observation.md).

- value_schema:

  Optional schema description for the payload.

- name:

  Source name.

## Value

A `har_source_kafka` object.

## Examples

``` r
# Stub example: a simulated collector, no broker required.
source <- har_source_kafka(
  topic = "sensor-events",
  bootstrap_servers = c("broker:9092"),
  group_id = "harbinger",
  collector = har_simulated_collector(c(10, 11, 12, 20, 12))
)
next_observation(source)$observation$value
#> [1] 10

# Real example: a collector backed by a live Kafka client (user code).
if (FALSE) { # \dontrun{
kafka_collector <- function(consumer) {
  obj <- list(
    get_next = function() {
      msg <- reticulate::iter_next(consumer, completed = NULL)
      if (is.null(msg)) NULL else as.numeric(msg$value)
    },
    close = function() consumer$close()
  )
  class(obj) <- append("kafka_collector", "har_stream_collector")
  obj
}
# consumer <- reticulate::import("kafka")$KafkaConsumer("sensor-events", ...)
# source <- har_source_kafka("sensor-events", c("broker:9092"), "harbinger",
#                            collector = kafka_collector(consumer))
} # }
```
