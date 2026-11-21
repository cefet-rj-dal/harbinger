# Bayesian Online Change Point Detection – "++" re-implementation

Change-point detection with a native, self-contained Bayesian Online
Change Point Detector (no `ocp` dependency). This is an **adaptation**
of BOCPD (Adams & MacKay 2007) with documented innovations over the
`ocp` backend:

1.  **Autoregressive UPM.** `ocp` uses an i.i.d. Gaussian underlying
    predictive model, which only sees shifts in level and variance. Here
    the per-run-length model is a conjugate *Bayesian linear
    autoregression* (a regression of x_t on `[1, x_{t-1}, ...]`,
    Normal-Inverse-Gamma prior, Student-t predictive), so it also
    detects changes in dynamics (slope, trend, autocorrelation).

2.  **Log-space + eps-pruning.** The run-length recursion runs in
    log-space and the run-length distribution is pruned to the entries
    holding all but a fraction `prune_eps` of the peak mass – a
    bounded-state, streaming recursion.

3.  **Surprise-based extraction.** Change points are read from the
    Bayesian predictive surprise `-log p(x_t | x_{1:t-1})` via a causal
    robust local z-score, replacing `ocp`'s noisy three-list voting.

This mirrors the canonical implementation in the `pyharbinger` package
(class `HcpBocpd`); the two implementations produce identical
detections.

## Usage

``` r
hcp_bocpd(
  hazard = 250,
  threshold = 6,
  min_distance = 15,
  burn_in = 5,
  order = 1,
  local_window = 20,
  prune_eps = 1e-06
)
```

## Arguments

- hazard:

  Positive scalar; the prior change probability per step is
  `1 / hazard`.

- threshold:

  Local z-score a surprise peak must reach to be flagged.

- min_distance:

  Minimum distance between selected change points.

- burn_in:

  Number of initial observations to ignore.

- order:

  Autoregressive order of the UPM (regressors `[1, x_{t-1}, ...]`).

- local_window:

  Trailing window of the robust local z-score baseline.

- prune_eps:

  Run lengths below `prune_eps` times the peak mass are pruned.

## Value

An `hcp_bocpd` object.

## References

- Adams RP, MacKay DJC (2007). Bayesian Online Changepoint Detection.
  arXiv:0710.3742.

- Fearnhead P, Liu Z (2007). On-line inference for multiple changepoint
  problems. J. R. Stat. Soc. B, 69(4):589-605. (online inference with
  resampling/pruning of the run-length distribution; segment regression
  models)

- Fearnhead P (2006). Exact and efficient Bayesian inference for
  multiple changepoint problems. Statistics and Computing,
  16(2):203-213. (Bayesian linear-regression segment models)

- Saatci Y, Turner R, Rasmussen CE (2010). Gaussian Process Change Point
  Models. ICML. (BOCPD with richer predictive models and run-length
  pruning)

- Takeuchi J, Yamanishi K (2006). A unifying framework for detecting
  outliers and change points from time series. IEEE TKDE, 18(4):482-492.
  (autoregressive change-point surprise)

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

# Configure BOCPD detector
model <- hcp_bocpd()

# Fit the model (no-op; detection is self-contained)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection[(detection$event),])
#>    idx event        type
#> 51  51  TRUE changepoint
```
