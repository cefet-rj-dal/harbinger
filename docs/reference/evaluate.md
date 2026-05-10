# Fit a model for event detection

Basic ancestor function for build model for event detection

## Usage

``` r
evaluate(obj, ...)
```

## Arguments

- obj:

  harbinger object

- ...:

  optional arguments./ further arguments passed to or from other
  methods.

## Value

a harbinger object with model details

## Details

The fit function builds a model for time series event detection. For
some methods, the model is not needed to be build, so the function do
nothing.

## Examples

``` r
evaluation <- har_eval()
evaluation <- evaluate(evaluation, c(1, 0, 1, 0), c(0, 0, 1, 0))
```
