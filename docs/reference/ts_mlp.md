# Time Series Multilayer Perceptron (MLP)

Type of artificial neural network used to make predictions and forecasts
based on time series data. Consists of multiple layers of interconnected
nodes or neurons, using a supervised learning algorithm, which processes
the input data and passes it on. The output of the final layer provides
the predicted values for the future.

## Usage

``` r
ts_mlp(preprocess = NA, input_size = NA, size = NA, decay = 0.01, maxit = 1000)
```

## Value

a `ts_mlp` object.
