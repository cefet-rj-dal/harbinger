# Generalized Fluctuation Test (GFT)

Structural change detection using generalized fluctuation tests via
[`strucchange::breakpoints()`](https://rdrr.io/pkg/strucchange/man/breakpoints.html)
<doi:10.18637/jss.v007.i02>.

## Usage

``` r
hcp_gft()
```

## Value

`hcp_gft` object

## References

- Zeileis A, Leisch F, Kleiber C, Hornik K (2002). strucchange: An R
  package for testing for structural change in linear regression models.
  Journal of Statistical Software, 7(2). doi:10.18637/jss.v007.i02

- Zeileis A, Kleiber C, Krämer W, Hornik K (2003). Testing and dating of
  structural changes in practice. Computational Statistics & Data
  Analysis, 44(1):109–123.

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

# Configure the GFT detector
model <- hcp_gft()

# Fit the detector (no-op for GFT)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 49  49  TRUE changepoint
#> 69  69  TRUE changepoint
```
