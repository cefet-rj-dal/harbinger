# Harbinger Utilities

Utility object that groups helper functions used by Harbinger detectors.

## Usage

``` r
harutils()
```

## Value

A `harutils` object exposing the helper functions.

## Details

These helpers naturally fall into semantic groups rather than a single
homogeneous toolbox.

**Deviation measures**

- `har_deviation_l1()` and `har_deviation_l2()` aggregate magnitudes
  over vectors or over rows of matrices/data frames.

- `har_deviation_huber()` applies the Huber loss, combining quadratic
  behavior near zero with linear growth in the tails. This makes the
  score less sensitive to extreme residual peaks than `L2`, while still
  differentiating moderate and large residuals more smoothly than `L1`.

- They are typically used to transform residual series or reconstruction
  errors into a univariate score before thresholding.

**Filter criteria**

- `har_filter_none()` disables thresholding.

- `har_filter_boxplot()` uses the boxplot/IQR rule.

- `har_filter_gaussian()` uses the Gaussian 3-sigma rule.

- `har_filter_mad()` uses a robust median-plus-MAD cutoff.

- `har_filter_grubbs()` applies an iterative Grubbs test.

- `har_filter_ratio()` applies a ratio-based threshold rule.

For `har_filter_mad()`, the residual center is estimated by the sample
median and the scale by the median absolute deviation (MAD), rescaled by
`1.4826` by default so that it is consistent with the standard deviation
under Gaussian data. This makes the rule robust when the residual
distribution is skewed or already contains a few extreme points.

For `har_filter_grubbs()`, the returned `threshold` attribute is an
empirical detection boundary intended for interpretability in residual
plots: it records the least extreme detected value on each side. This
keeps the cutoff visually meaningful even though the Grubbs decision
itself is iterative. The function also returns a `score` attribute with
the Grubbs `G` statistic at each detected position and `NA` elsewhere.

**Candidate selection**

- `har_candidate_selection_firstgroup()` keeps the first index in each
  contiguous outlier run.

- `har_candidate_selection_highgroup()` keeps the highest-magnitude
  index in each contiguous outlier run.

- `har_candidate_selection_referencedistribution()` compares each
  candidate point in a contiguous run against the same reference window
  composed of the observations immediately preceding the start of that
  run. In the current implementation, the reference window is summarized
  by a Gaussian model, and points outside the accepted region remain
  marked. This lets sequence anomalies emerge naturally without
  collapsing the run to a single index. When there is not enough history
  to form the reference window, the first point of the run is kept.

- `har_fuzzify_detections_triangle()` propagates a detection score
  around an event within a tolerance window.

This organization makes it easier to swap only one semantic stage of the
pipeline: score construction, filter definition, or candidate selection.

## References

- Tukey JW (1977). Exploratory Data Analysis. Addison-Wesley.
  (boxplot/IQR heuristic)

- Shewhart WA (1931). Economic Control of Quality of Manufactured
  Product. D. Van Nostrand. (three-sigma rule)

- Huber PJ (1964). Robust Estimation of a Location Parameter. Annals of
  Mathematical Statistics, 35(1), 73-101. doi:10.1214/aoms/1177703732

- Huber PJ, Ronchetti EM (2009). Robust Statistics, 2nd ed. Wiley.

- Hampel FR, Ronchetti EM, Rousseeuw PJ, Stahel WA (1986). Robust
  Statistics: The Approach Based on Influence Functions. Wiley.

- Grubbs FE (1969). Procedures for Detecting Outlying Observations in
  Samples. Technometrics, 11(1), 1-21.
  doi:10.1080/00401706.1969.10490657

- Silva, E. P., Balbi, H., Pacitti, E., Porto, F., Santos, J.,
  Ogasawara, E. Cutoff Frequency Adjustment for FFT-Based Anomaly
  Detectors. In: Simpósio Brasileiro de Banco de Dados (SBBD). SBC, 14
  Oct. 2024. doi:10.5753/sbbd.2024.243319

## Examples

``` r
# Basic usage of utilities
utils <- harutils()

# Compute L2 distance on residuals
res <- c(0.1, -0.5, 1.2, -0.3)
d2 <- utils$har_deviation_l2(res)
print(d2)
#> [1] 0.01 0.25 1.44 0.09

# Huber deviation offers a smoother robust alternative
dh <- utils$har_deviation_huber(res)
print(dh)
#> [1] 0.005 0.125 0.720 0.045

# Apply 3-sigma outlier rule and keep only first index of contiguous runs
idx <- utils$har_filter_gaussian(d2)
flags <- utils$har_candidate_selection_firstgroup(idx, d2)
print(which(flags))
#> integer(0)

# MAD filter uses a robust location/scale summary
midx <- utils$har_filter_mad(c(d2, 8))
print(attr(midx, "threshold"))
#> [1] -0.817472  1.317472

# Grubbs outlier rule with an interpretable plotting threshold
gidx <- utils$har_filter_grubbs(c(d2, 8))
print(attr(gidx, "threshold"))
#> [1]   NA 1.44
print(attr(gidx, "score")[gidx])
#> [1] 1.483231 1.763093

# Sequence-aware candidate selection using a reference distribution
idx2 <- c(31, 32, 33)
flags2 <- utils$har_candidate_selection_referencedistribution(
  idx2,
  c(rep(0, 30), 4, 5, 4.5),
  c(rep(0, 30), 4, 5, 4.5)
)
print(which(flags2))
#> [1] 31 32 33
```
