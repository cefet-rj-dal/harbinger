# Chow Test (structural break)

Change-point detection for linear models using F-based structural break
tests from the strucchange package <doi:10.18637/jss.v007.i02>. It wraps
the Fstats and breakpoints implementation available in the strucchange
library.

## Usage

``` r
hcp_chow()
```

## Value

`hcp_chow` object

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

# Configure the Chow detector
model <- hcp_chow()

# Fit the detector (no-op for Chow)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 50  50  TRUE changepoint
```
