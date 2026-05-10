# Change Finder using ETS

Change-point detection by modeling residual deviations with ETS and
applying a second-stage smoothing and thresholding, inspired by
ChangeFinder <doi:10.1109/TKDE.2006.1599387>. Wraps ETS from the
`forecast` package.

## Usage

``` r
hcp_cf_ets(sw_size = 7)
```

## Arguments

- sw_size:

  Integer. Sliding window size for smoothing/statistics.

## Value

`hcp_cf_ets` object.

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

# Configure ChangeFinder-ETS detector
model <- hcp_cf_ets()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 51  51  TRUE changepoint
```
