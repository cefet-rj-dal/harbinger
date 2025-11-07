# Harbinger Utilities

Utility object that groups common distance measures, threshold
heuristics, and outlier grouping rules used by Harbinger detectors.

## Usage

``` r
harutils()
```

## Value

A `harutils` object exposing the helper functions.

## Details

Provided helpers include:

- L1 and L2 distance aggregations over vectors or rows of matrices/data
  frames.

- Thresholding heuristics: boxplot-based (IQR), Gaussian 3-sigma, and a
  ratio-based rule.

- Grouping strategies for contiguous outliers: keep first index or keep
  highest-magnitude index.

- Optional fuzzification over detections to propagate influence within a
  tolerance window.

These utilities centralize common tasks and ensure consistent behavior
across detectors.

## References

- Tukey JW (1977). Exploratory Data Analysis. Addison-Wesley.
  (boxplot/IQR heuristic)

- Shewhart WA (1931). Economic Control of Quality of Manufactured
  Product. D. Van Nostrand. (three-sigma rule)

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
d2 <- utils$har_distance_l2(res)
print(d2)
#> [1] 0.01 0.25 1.44 0.09

# Apply 3-sigma outlier rule and keep only first index of contiguous runs
idx <- utils$har_outliers_gaussian(d2)
flags <- utils$har_outliers_checks_firstgroup(idx, d2)
print(which(flags))
#> integer(0)
```
