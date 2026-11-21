# Change Finder (robust), autoregressive SDAR – "++" re-implementation

Change-point detection with a native, self-contained robust ChangeFinder
(no `forecast` dependency). This is an **adaptation** of the original
ChangeFinder-ARIMA with documented innovations: instead of scoring
[`forecast::auto.arima`](https://pkg.robjhyndman.com/forecast/reference/auto.arima.html)
residuals, it implements the *canonical* two-stage online SDAR
(Sequentially Discounting AutoRegressive) ChangeFinder of Takeuchi &
Yamanishi (2006) – strong on abrupt/variance/multi-change regimes – and
takes the **union** with a Gaussian mean+variance structural break
(shared with `hcp_chow`/`hcp_gft`), which recovers the smooth
trend/slope changes the AR-surprise score is blind to.

This mirrors the canonical implementation in the `pyharbinger` package
(class `HcpCfArima`); the two implementations produce identical
detections.

## Usage

``` r
hcp_cf_arima(sw_size = 5, r = 0.07, order = 1, h = 0.15)
```

## Arguments

- sw_size:

  Integer. Smoothing window for the two-stage scores / warm-up.

- r:

  SDAR forgetting (discounting) factor.

- order:

  Autoregressive order of the SDAR model.

- h:

  Minimal segment fraction for the mean+variance structural break.

## Value

`hcp_cf_arima` object.

## References

- Takeuchi J, Yamanishi K (2006). A unifying framework for detecting
  outliers and change points from time series. IEEE Transactions on
  Knowledge and Data Engineering, 18(4):482-492.

- Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis.
  Birkhauser. (mean+variance structural break)

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

# Configure ChangeFinder-ARIMA detector
model <- hcp_cf_arima()

# Fit the model (no-op; detection is self-contained)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 49  49  TRUE changepoint
```
