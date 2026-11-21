# Chow Test (structural break), scale-aware re-implementation

Change-point detection by structural break in a linear model. This is a
native re-implementation (no `strucchange` dependency) and an
**adaptation** of the original Chow/`strucchange` approach with a
documented innovation: where the classical Chow test only compares the
*mean* regression coefficients of the two sub-samples (homoskedastic
errors), this version reports the single break that maximises the
Gaussian *mean + variance* log-likelihood ratio over an unknown break
date. It is therefore scale-aware – it also detects variance/scale
regime changes the mean-only Chow test is blind to. The break is scanned
over the trimmed range following the sup-type construction of Andrews
(1993).

This mirrors the canonical implementation in the `pyharbinger` package
(class `HcpChow`); the two implementations produce identical detections.

## Usage

``` r
hcp_chow()
```

## Value

`hcp_chow` object

## References

- Chow GC (1960). Tests of equality between sets of coefficients in two
  linear regressions. Econometrica, 28(3):591-605.

- Andrews DWK (1993). Tests for parameter instability and structural
  change with unknown change point. Econometrica, 61(4):821-856.

- Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis.
  Birkhauser. (Gaussian mean+variance change points)

- Zeileis A, Leisch F, Hornik K, Kleiber C (2002). strucchange: An R
  package for testing for structural change in linear regression models.
  Journal of Statistical Software, 7(2). doi:10.18637/jss.v007.i02
  (original approach)

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
#> 49  49  TRUE changepoint
```
