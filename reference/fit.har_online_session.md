# Fit an online session

Consumes the warm-up observations and optionally fits the wrapped
detector according to the execution strategy.

## Usage

``` r
# S3 method for class 'har_online_session'
fit(obj, ...)
```

## Arguments

- obj:

  Online session.

- ...:

  Additional arguments forwarded to the wrapped detector `fit()` method
  when warm-up fitting is enabled.

## Value

Updated `har_online_session`.
