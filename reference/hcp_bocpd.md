# Bayesian Online Change Point Detection

Online Bayesian change-point detection using the `ocp` package.

This implementation follows the Adams & MacKay formulation and uses the
`ocp` backend to infer changepoint evidence over the full series.

## Usage

``` r
hcp_bocpd(
  hazard = 100,
  dist = c("gaussian", "poisson"),
  threshold = NULL,
  min_distance = 5,
  burn_in = 5
)
```

## Arguments

- hazard:

  Positive scalar controlling the constant hazard function.

- dist:

  Probability model used by `ocp`; one of `"gaussian"` or `"poisson"`.

- threshold:

  Numeric threshold for changepoint evidence.

- min_distance:

  Minimum distance between selected changepoints.

- burn_in:

  Number of initial observations to ignore.

## Value

An `hcp_bocpd` object.

## References

- Adams RP, MacKay DJC (2007). Bayesian Online Changepoint Detection.
  arXiv:0710.3742

- Pagotto A (2019). ocp: Bayesian Online Changepoint Detection. R
  package.
