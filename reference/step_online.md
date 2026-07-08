# Step an online session once

Consumes at most one new observation and triggers one batch detection
cycle when the batch threshold is reached.

## Usage

``` r
step_online(obj, ...)
```

## Arguments

- obj:

  Online session.

- ...:

  Additional arguments forwarded to wrapped detector methods.

## Value

Updated `har_online_session`.
