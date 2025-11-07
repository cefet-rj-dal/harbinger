# Moving average smoothing

The `mas()` function returns a simple moving average smoother of the
provided time series.

## Usage

``` r
mas(x, order)
```

## Arguments

- x:

  A numeric vector or univariate time series.

- order:

  Order of moving average smoother.

## Value

Numerical time series of length `length(x)-order+1` containing the
simple moving average smoothed values.

## Details

The moving average smoother transformation is given by \$\$(1/k) \* (
x\[t\] + x\[t+1\] + ... + x\[t+k-1\] )\$\$ where `k=order`, `t` assume
values in the range `1:(n-k+1)`, and `n=length(x)`. See also the
[`ma`](https://pkg.robjhyndman.com/forecast/reference/ma.html) of the
`forecast` package.

## References

R.H. Shumway and D.S. Stoffer, 2010, Time Series Analysis and Its
Applications: With R Examples. 3rd ed. 2011 edition ed. New York,
Springer.

## Examples

``` r
# Load change-point example data
data(examples_changepoints)

# Use a simple example
dataset <- examples_changepoints$simple
head(dataset)
#>   serie event
#> 1  0.00 FALSE
#> 2  0.25 FALSE
#> 3  0.50 FALSE
#> 4  0.75 FALSE
#> 5  1.00 FALSE
#> 6  1.25 FALSE

# Compute a 5-point moving average
ma <- mas(dataset$serie, 5)
```
