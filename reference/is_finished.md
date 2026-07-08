# Test whether an online session has finished

Returns `TRUE` when there is no queued observation left and the pull
source is exhausted. In push mode, the session is considered finished
when the queue is empty.

## Usage

``` r
is_finished(obj)
```

## Arguments

- obj:

  Online session.

## Value

Logical scalar.
