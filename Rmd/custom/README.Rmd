---
title: "Custom — Extension Examples"
output: github_document
---

# Custom — Extension Examples

This section mirrors one of the central ideas behind Harbinger: the package is not only a collection of built-in detectors, but also a framework that can be extended with new detectors, transformations, and evaluation strategies.

The examples in this folder are intentionally didactic. Each one shows the smallest useful contract for a different type of extension:

- define a constructor;
- store the configuration inside the object;
- implement the expected S3 methods;
- reuse the regular Harbinger workflow around that custom class.

## Recommended reading order

1. [custom_transformation.md](/examples/custom/custom_transformation.md) — a custom median filter used before detection
2. [custom_anomaly.md](/examples/custom/custom_anomaly.md) — a custom anomaly detector based on `forecast::tsoutliers()`
3. [custom_sequence_anomaly.md](/examples/custom/custom_sequence_anomaly.md) — a custom collective-anomaly detector that returns full anomalous ranges instead of a single representative point
4. [custom_change_point.md](/examples/custom/custom_change_point.md) — a custom joinpoint-regression detector using `segmented`
5. [custom_motif.md](/examples/custom/custom_motif.md) — a custom motif detector based on DTW subsequence clustering
6. [custom_evaluation.md](/examples/custom/custom_evaluation.md) — a custom range-aware evaluator for anomalous intervals
