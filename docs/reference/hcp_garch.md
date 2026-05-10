# Change Finder using GARCH

Change-point detection for variance shifts using a GARCH-based residual
model. The detector flags change points when the observed series departs
from the expected volatility pattern estimated by the fitted GARCH
model. Wraps the GARCH model presented in the `rugarch` package.

## Usage

``` r
hcp_garch(sw_size = 5)
```

## Arguments

- sw_size:

  Sliding window size

## Value

`hcp_garch` object

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## Examples

``` r
library(daltoolbox)

# Load change-point example data
data(examples_changepoints)

# Use a volatility example
dataset <- examples_changepoints$volatility
head(dataset)
#>         serie event
#> 1  1.61424200 FALSE
#> 2  1.19696424 FALSE
#> 3 -0.02275846 FALSE
#> 4 -2.22607912 FALSE
#> 5  0.01189136 FALSE
#> 6 -0.03898793 FALSE

# Configure ChangeFinder-GARCH detector
model <- hcp_garch()

# Fit the model
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>     idx event        type
#> 196 196  TRUE changepoint
```
