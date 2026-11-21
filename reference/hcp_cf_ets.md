# Change Finder (robust), discounted Holt – "++" re-implementation

Change-point detection with a native, self-contained robust ChangeFinder
(no `forecast` dependency). This is an **adaptation** of the original
ChangeFinder-ETS with documented innovations: instead of scoring
[`forecast::ets`](https://pkg.robjhyndman.com/forecast/reference/ets.html)
residuals, it implements the canonical two-stage online ChangeFinder of
Takeuchi & Yamanishi (2006) with a *discounted Holt* (level+trend, the
exponential-smoothing analogue of SDAR) predictor, and takes the
**union** with a Gaussian mean+variance structural break (shared with
`hcp_chow`/`hcp_gft`), which recovers smooth trend/slope changes the
surprise score is blind to.

This mirrors the canonical implementation in the `pyharbinger` package
(class `HcpCfEts`); the two implementations produce identical
detections.

## Usage

``` r
hcp_cf_ets(sw_size = 5, alpha = 0.8, beta = 0.1, r = 0.05, h = 0.15)
```

## Arguments

- sw_size:

  Integer. Smoothing window for the two-stage scores / warm-up.

- alpha:

  Holt level smoothing factor.

- beta:

  Holt trend smoothing factor.

- r:

  Forgetting (discounting) factor for the residual variance.

- h:

  Minimal segment fraction for the mean+variance structural break.

## Value

`hcp_cf_ets` object.

## References

- Takeuchi J, Yamanishi K (2006). A unifying framework for detecting
  outliers and change points from time series. IEEE Transactions on
  Knowledge and Data Engineering, 18(4):482-492.

- Holt CC (1957/2004). Forecasting seasonals and trends by exponentially
  weighted moving averages. International Journal of Forecasting,
  20(1):5-10.

- Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis.
  Birkhauser.

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

# Fit the model (no-op; detection is self-contained)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 49  49  TRUE changepoint
```
