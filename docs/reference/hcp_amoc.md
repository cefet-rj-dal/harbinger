# At Most One Change (AMOC)

Change-point detection method focusing on identifying at most one change
in mean and/or variance. This is a wrapper around the AMOC
implementation from the `changepoint` package.

## Usage

``` r
hcp_amoc()
```

## Value

`hcp_amoc` object.

## Details

AMOC detects a single most significant change point under a cost
function optimized for a univariate series. It is useful when at most
one structural break is expected.

## References

- Hinkley DV (1970). Inference about the change-point in a sequence of
  random variables. Biometrika, 57(1):1–17. doi:10.1093/biomet/57.1.1

- Killick R, Fearnhead P, Eckley IA (2012). Optimal detection of
  changepoints with a linear computational cost. JASA,
  107(500):1590–1598.

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

# Configure the AMOC detector
model <- hcp_amoc()

# Fit the detector (no-op for AMOC)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change point(s)
print(detection[(detection$event),])
#>    idx event        type
#> 84  84  TRUE changepoint
```
