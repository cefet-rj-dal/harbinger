# Fit

Models a time series dataset by estimating the underlying trend and
seasonality components. Used to make predictions and forecast future
values of the time series based on the historical data.

Basic ancestor function for build model for event detection

## Usage

``` r
fit(obj, ...)

fit(obj, ...)
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
data(examples_anomalies)
dataset <- examples_anomalies[[1]]
detector <- harbinger()
detector <- fit(detector, dataset$serie)
```
