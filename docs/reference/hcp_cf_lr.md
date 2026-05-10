# Change Finder using Linear Regression

Change-point detection by modeling residual deviations with linear
regression and applying a second-stage smoothing and thresholding,
inspired by ChangeFinder <doi:10.1109/TKDE.2006.1599387>.

## Usage

``` r
hcp_cf_lr(sw_size = 30)
```

## Arguments

- sw_size:

  Integer. Sliding window size for smoothing/statistics.

## Value

`hcp_cf_lr` object.

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

# Configure ChangeFinder-LR detector
model <- hcp_cf_lr()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#> [1] idx   event type 
#> <0 rows> (or 0-length row.names)
```
