# Time Series Support Vector Machine

Transform data into vectors of features. The algorithm then identifies
the support vectors that define the hyperplane that best separates the
data into different classes based on temporal proximity. The hyperplane
can then be used to make predictions about future values of the time
series.

## Usage

``` r
ts_svm(
  preprocess = NA,
  input_size = NA,
  kernel = "radial",
  epsilon = 0,
  cost = 10
)
```

## Value

a `ts_svm` object.
