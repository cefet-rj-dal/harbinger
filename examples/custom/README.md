---
title: "Custom — Extension Examples"
output: github_document
---

# Custom — Extension Examples

This section mirrors one of the central ideas behind Harbinger: the package is not only a collection of built-in detectors, but also a framework that can be extended with new detectors, transformations, and evaluation strategies.

The examples are ordered by the kind of contract being extended, so a learner can understand one extension point at a time.

## Extension path

1. [01-transformation-custom_transformation.md](/examples/custom/01-transformation-custom_transformation.md) — a custom median filter used before detection
2. [02-anomaly-custom_anomaly.md](/examples/custom/02-anomaly-custom_anomaly.md) — a custom anomaly detector based on `forecast::tsoutliers()`
3. [03-sequence-custom_sequence_anomaly.md](/examples/custom/03-sequence-custom_sequence_anomaly.md) — a custom collective-anomaly detector that returns full anomalous ranges instead of a single representative point
4. [04-change-point-custom_change_point.md](/examples/custom/04-change-point-custom_change_point.md) — a custom joinpoint-regression detector using `segmented`
5. [05-motif-custom_motif.md](/examples/custom/05-motif-custom_motif.md) — a custom motif detector based on DTW subsequence clustering
6. [06-evaluation-custom_evaluation.md](/examples/custom/06-evaluation-custom_evaluation.md) — a custom range-aware evaluator for anomalous intervals
