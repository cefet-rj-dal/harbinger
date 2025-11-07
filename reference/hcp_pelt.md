# Pruned Exact Linear Time (PELT)

Multiple change-point detection using the PELT algorithm for
mean/variance with a linear-time cost under suitable penalty choices.
This function wraps the PELT implementation in the `changepoint`
package.

## Usage

``` r
hcp_pelt()
```

## Value

`hcp_pelt` object.

## Details

PELT performs optimal partitioning while pruning candidate change-point
locations to achieve near-linear computational cost.

## References

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

# Configure the PELT detector
model <- hcp_pelt()

# Fit the detector (no-op for PELT)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 9    9  TRUE changepoint
#> 19  19  TRUE changepoint
#> 29  29  TRUE changepoint
#> 39  39  TRUE changepoint
#> 60  60  TRUE changepoint
#> 71  71  TRUE changepoint
#> 81  81  TRUE changepoint
#> 91  91  TRUE changepoint
```
