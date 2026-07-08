# Simulated source

Creates a replay source from an in-memory vector or data frame. This is
the recommended source for reproducible streaming experiments and is the
direct replacement for the simulated data flow used in the Nexus
prototype.

## Usage

``` r
har_source_simulated(data, timestamp = NULL, name = "simulated")
```

## Arguments

- data:

  Numeric vector, matrix, or data frame containing observations in time
  order.

- timestamp:

  Optional vector with one timestamp per observation.

- name:

  Source name.

## Value

A `har_source_simulated` object.

## Examples

``` r
source <- har_source_simulated(c(1, 2, 3))
obs <- next_observation(source)
obs$observation$value
#> [1] 1
```
