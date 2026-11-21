# Generalized Fluctuation Test (GFT), scale-aware re-implementation

Structural change detection by multiple breaks in a linear model. This
is a native re-implementation (no `strucchange` dependency) and an
**adaptation** of the original `strucchange::breakpoints` approach with
documented innovations: (1) the least-squares (mean-only) Bai & Perron
breakpoints are generalised to a Gaussian *mean + variance* segmentation
cost (each segment pays the ML deviance `m * log(RSS/m)` with a
per-segment variance), so breaks in scale/variance regimes are detected,
not only breaks in the mean/trend; (2) the number of breaks is chosen by
the conservative LWZ information criterion (Liu, Wu & Zidek 1997)
instead of the Gaussian BIC, which curbs over-segmentation; (3) the
Bai-Perron dynamic program is vectorised.

This mirrors the canonical implementation in the `pyharbinger` package
(class `HcpGft`); the two implementations produce identical detections.

## Usage

``` r
hcp_gft(penalty = "lwz")
```

## Arguments

- penalty:

  break-count information criterion: `"lwz"` (default, conservative) or
  `"bic"`.

## Value

`hcp_gft` object

## References

- Bai J, Perron P (1998). Estimating and testing linear models with
  multiple structural changes. Econometrica, 66(1):47-78.

- Bai J, Perron P (2003). Computation and analysis of multiple
  structural change models. Journal of Applied Econometrics, 18(1):1-22.

- Liu J, Wu S, Zidek JV (1997). On segmented multivariate regression.
  Statistica Sinica, 7:497-525. (LWZ information criterion)

- Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis.
  Birkhauser. (Gaussian mean+variance change points)

- Killick R, Fearnhead P, Eckley IA (2012). Optimal detection of
  changepoints with a linear computational cost. JASA,
  107(500):1590-1598.

- Zeileis A, Leisch F, Kleiber C, Hornik K (2002). strucchange: An R
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
```
