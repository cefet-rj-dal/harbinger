# Run an online session

Processes the session until the pull source is exhausted and the push
queue is empty, or until a fixed number of online detection cycles has
been executed.

## Usage

``` r
run_online(obj, max_batches = NULL, ...)
```

## Arguments

- obj:

  Online session.

- max_batches:

  Optional maximum number of detection cycles to execute.

- ...:

  Additional arguments forwarded to wrapped detector methods.

## Value

Updated `har_online_session`.
