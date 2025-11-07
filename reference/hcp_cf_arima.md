# Change Finder using ARIMA

Change-point detection by modeling residual deviations with ARIMA and
applying a second-stage smoothing and thresholding, inspired by
ChangeFinder <doi:10.1109/TKDE.2006.1599387>. Wraps ARIMA from the
`forecast` package.

## Usage

``` r
hcp_cf_arima(sw_size = NULL)
```

## Arguments

- sw_size:

  Integer. Sliding window size for smoothing/statistics.

## Value

`hcp_cf_arima` object.

## References

- Takeuchi J, Yamanishi K (2006). A unifying framework for detecting
  outliers and change points from time series. IEEE Transactions on
  Knowledge and Data Engineering.

## Examples

``` r
library(daltoolbox)

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

# Configure ChangeFinder-ARIMA detector
model <- hcp_cf_arima()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 51  51  TRUE changepoint
```
