# Joinpoint Regression++ change-point detector

Piecewise linear change-point detection based on Joinpoint Regression++.

The detector searches for a globally optimal set of joinpoints with
dynamic programming, fits linear segments between candidate breaks, and
compares models with `0` to `k_max` joinpoints using BIC, BIC3, and a
weighted BIC (WBIC) criterion.

This implementation is intended for univariate numeric series and
follows the same family of ideas used by the National Cancer Institute
Joinpoint Regression Program, but it is documented here as a Joinpoint
Regression++ variant because it replaces brute-force breakpoint
enumeration with dynamic programming and weighted model selection while
keeping a lightweight Harbinger-compatible API.

## Usage

``` r
hcp_joinpoint(min_between = 2, min_end = 2, k_max = 5, log_transform = FALSE)
```

## Arguments

- min_between:

  Minimum number of observations between consecutive joinpoints.

- min_end:

  Minimum number of observations required in the first and last
  segments.

- k_max:

  Maximum number of joinpoints considered during model selection.

- log_transform:

  Logical indicating whether the series should be log transformed before
  fitting. This is useful for multiplicative trends and growth-rate
  interpretation.

## Value

An `hcp_joinpoint` object.

## References

- Kim HJ, Fay MP, Feuer EJ, Midthune DN (2000). Permutation Tests for
  Joinpoint Regression with Applications to Cancer Rates. Statistics in
  Medicine, 19(3), 335-351.
  \<doi:10.1002/(SICI)1097-0258(20000215)19:3\<335::AID-SIM336\>3.0.CO;2-Z\>

- Kim HJ, Chen HS, Midthune D, Wheeler B, Buckman DW, Green D, Byrne J,
  Luo J, Feuer EJ (2023). Data-driven choice of a model selection method
  in joinpoint regression. Journal of Applied Statistics, 50(9),
  1992-2013. <doi:10.1080/02664763.2022.2063265>

- National Cancer Institute. Joinpoint Trend Analysis Software.
  https://surveillance.cancer.gov/joinpoint/
