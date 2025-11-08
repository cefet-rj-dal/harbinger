---
title: "General — Examples Index"
output: github_document
---

# General — Examples Index

This directory contains overview notebooks, utilities, and evaluation examples for Harbinger.

## Examples

- [examples_anomalies.md](/examples/general/examples_anomalies.md) — Overview and objectives: This notebook tours common time-series anomaly patterns (point/isolated, contextual, collective/sequence, regime variance shifts) using Harbinger's base pipeline.
- [examples_changepoints.md](/examples/general/examples_changepoints.md) — Overview and objectives: This notebook illustrates typical change-point scenarios (single break, multiple breaks, variance/volatility shifts) and how Harbinger visualizes detected change locations.
- [examples_harbinger.md](/examples/general/examples_harbinger.md) — Overview and objectives: This notebook provides quick end-to-end demonstrations of the default `harbinger()` pipeline across diverse datasets (nonstationarity, global temperature monthly/yearly, multivariate, and weather).
- [examples_harutils_distance.md](/examples/general/examples_harutils_distance.md) — Overview and objectives: This notebook demonstrates Harbinger utility distance functions for summarizing residual magnitudes (L1 and L2) and plotting results for quick inspection.
- [examples_harutils_outliers.md](/examples/general/examples_harutils_outliers.md) — Overview and objectives: This notebook shows how Harbinger's utility functions for distance aggregation, thresholding, and grouping affect anomaly flags and decision thresholds.
- [examples_motifs.md](/examples/general/examples_motifs.md) — Overview and objectives: This notebook showcases motif discovery (repeated subsequences) using Harbinger's unified interface and base plotting.
- [har_eval_soft.md](/examples/general/har_eval_soft.md) — Overview and objectives: SoftED provides soft evaluation by matching detections to ground truth within tolerance windows and assigning partial credit.
- [har_eval.md](/examples/general/har_eval.md) — Overview and objectives: This notebook demonstrates hard evaluation of event detection results using confusion matrix-based metrics (accuracy, precision, recall, F1).

