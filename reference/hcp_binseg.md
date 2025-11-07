# Binary Segmentation (BinSeg)

Multi-change-point detection via Binary Segmentation on mean/variance
using the `changepoint` package.

## Usage

``` r
hcp_binseg(Q = 2)
```

## Arguments

- Q:

  Integer. Maximum number of change points to search for.

## Value

`hcp_binseg` object.

## Details

Binary Segmentation recursively partitions the series around the largest
detected change until a maximum number of change points or stopping
criterion is met. This is a fast heuristic widely used in practice.

## References

- Vostrikova L (1981). Detecting "disorder" in multidimensional random
  processes. Soviet Mathematics Doklady, 24, 55–59.

- Killick R, Fearnhead P, Eckley IA (2012). Optimal detection of
  changepoints with a linear computational cost. JASA,
  107(500):1590–1598.
  [dplyr::context](https://dplyr.tidyverse.org/reference/context.html)

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

# Configure the BinSeg detector
model <- hcp_binseg()

# Fit the detector (no-op for BinSeg)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)
#> Warning: The number of changepoints identified is Q, it is advised to increase Q to make sure changepoints have not been missed.

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 19  19  TRUE changepoint
#> 85  85  TRUE changepoint
```
