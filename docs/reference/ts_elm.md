# Time Series Extreme Learning Machine (ELM)

Machine learning technique used for time series forecasting. ELM is a
type of feedforward neural network that uses a single hidden layer of
randomly generated neurons.

## Usage

``` r
ts_elm(preprocess = NA, input_size = NA, nhid = NA, actfun = "purelin")
```

## Arguments

- actfun:

  string: defines the type to use, possible values: 'sig', 'radbas',
  'tribas', 'relu', 'purelin' (default).

## Value

a `ts_elm` object.
