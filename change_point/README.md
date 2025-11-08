---
title: "Change Points — Examples Index"
output: github_document
---

# Change Points — Examples Index

This directory contains example R Markdown notebooks for change-point detection in Harbinger.

## Examples

- [hcp_amoc.md](/examples/change_point/hcp_amoc.md) — AMOC: AMOC targets a single most significant change point in a univariate series by optimizing a cost function over all possible change locations.
- [hcp_binseg.md](/examples/change_point/hcp_binseg.md) — BinSeg: Binary Segmentation recursively partitions the series around the largest detected change until a maximum number of change points or a stopping criterion is met.
- [hcp_cf_arima.md](/examples/change_point/hcp_cf_arima.md) — ChangeFinder with ARIMA: ChangeFinder with ARIMA models residual deviations and applies a second-stage smoothing/thresholding to highlight structural changes.
- [hcp_cf_ets.md](/examples/change_point/hcp_cf_ets.md) — ChangeFinder with ETS: ChangeFinder with ETS models residual deviations and applies a second-stage smoothing/thresholding to highlight structural changes.
- [hcp_cf_lr.md](/examples/change_point/hcp_cf_lr.md) — ChangeFinder with linear regression: ChangeFinder with linear regression models residual deviations and applies a second-stage smoothing/thresholding to expose structural changes.
- [hcp_chow.md](/examples/change_point/hcp_chow.md) — Chow tests: Chow tests for structural breaks in linear models using F-statistics over candidate breakpoints and returns estimated break locations.
- [hcp_garch.md](/examples/change_point/hcp_garch.md) — ChangeFinder with GARCH: ChangeFinder with GARCH models conditional variance dynamics; residual-based scores are smoothed and thresholded to flag volatility regime shifts.
- [hcp_gft.md](/examples/change_point/hcp_gft.md) — GFT: Generalized fluctuation tests assess stability of regression parameters over time using `strucchange::breakpoints()`, returning estimated break dates under information criteria.
- [hcp_pelt.md](/examples/change_point/hcp_pelt.md) — PELT: PELT performs optimal partitioning of the time series under a penalized cost function while pruning candidate change locations to achieve near-linear time under suitable penalties.
- [hcp_scp.md](/examples/change_point/hcp_scp.md) — SCP: Seminal Change Point compares linear regression fits with and without the central observation in sliding windows; large deviations around a center indicate a change location.

