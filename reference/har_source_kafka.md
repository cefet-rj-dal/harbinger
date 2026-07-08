# Kafka source stub

Creates a Kafka source placeholder that documents the expected
collection interface while keeping the actual broker integration outside
the Harbinger core. This object does not implement native Kafka
consumption in R.

A `python_collector`, typically created with `reticulate`, may be
attached to the source. Harbinger expects this collector to expose a
`get_next()` method returning one observation at a time according to the
same observation contract used by callback sources, and an optional
[`close()`](https://rdrr.io/r/base/connections.html) method.

## Usage

``` r
har_source_kafka(
  topic,
  bootstrap_servers,
  group_id,
  value_schema = NULL,
  python_collector = NULL,
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

- value_schema:

  Optional schema description for the payload.

- python_collector:

  Optional Python collector object integrated through `reticulate`. It
  is expected to expose `get_next()` and optionally
  [`close()`](https://rdrr.io/r/base/connections.html).

- name:

  Source name.

## Value

A `har_source_kafka` object.

## Examples

``` r
source <- har_source_kafka(
  topic = "sensor-events",
  bootstrap_servers = c("broker1:9092"),
  group_id = "harbinger-consumer"
)
try(next_observation(source))
#> Error : Kafka source is configured only as a stub. Attach a Python collector via reticulate.
```
