# Callback source

Creates a pull-style source that retrieves observations by calling an R
function. The callback must return either `NULL` when no observation is
available or an observation compatible with the online observation
contract. In practice this means a scalar, a one-row `data.frame`, or a
list containing at least a `value` field and optionally `idx`,
`timestamp`, and `payload`.

## Usage

``` r
har_source_callback(poll_fn, name = "callback")
```

## Arguments

- poll_fn:

  Function called to request the next observation.

- name:

  Source name.

## Value

A `har_source_callback` object.
