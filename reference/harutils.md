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

- They are typically used to transform residual series or reconstruction
  errors into a univariate score before thresholding.

**Filter criteria**

- `har_filter_none()` disables thresholding.

- `har_filter_boxplot()` uses the boxplot/IQR rule.

- `har_filter_gaussian()` uses the Gaussian 3-sigma rule.

- `har_filter_grubbs()` applies an iterative Grubbs test.

- `har_filter_ratio()` applies a ratio-based threshold rule.

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

# Apply 3-sigma outlier rule and keep only first index of contiguous runs
idx <- utils$har_filter_gaussian(d2)
flags <- utils$har_candidate_selection_firstgroup(idx, d2)
print(which(flags))
#> integer(0)

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
  c(rep(0, 30), 4, 5, 4.5)
)
#> Error in utils$har_candidate_selection_referencedistribution(idx2, c(rep(0,     30), 4, 5, 4.5)): argument "values" is missing, with no default
print(which(flags2))
#> Error: object 'flags2' not found
```
