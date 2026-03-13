# Custom Extension Examples

This section shows that `harbinger` is not only a catalog of built-in methods. It is also a framework with clear contracts for transformations, detectors, motif workflows, and evaluators.

The examples are ordered by extension point so the reader can study one kind of customization at a time. This helps the reader move from simpler adaptations to richer extensions without needing to infer every package contract from scratch.

If the goal is only to use the package, this folder can wait. If the goal is to extend the package or connect Harbinger with an external library, this is the place to read carefully.

- [01-transformation-custom_transformation.md](/examples/custom/01-transformation-custom_transformation.md) - create a custom transformation based on a median filter.
- [02-anomaly-custom_anomaly.md](/examples/custom/02-anomaly-custom_anomaly.md) - wrap `forecast::tsoutliers()` as a custom anomaly detector.
- [03-sequence-custom_sequence_anomaly.md](/examples/custom/03-sequence-custom_sequence_anomaly.md) - implement a collective-anomaly detector that returns anomalous ranges.
- [04-change-point-custom_change_point.md](/examples/custom/04-change-point-custom_change_point.md) - build a custom change-point detector with `segmented`.
- [05-motif-custom_motif.md](/examples/custom/05-motif-custom_motif.md) - create a custom motif detector with DTW subsequence clustering.
- [06-evaluation-custom_evaluation.md](/examples/custom/06-evaluation-custom_evaluation.md) - define a range-aware evaluator for anomalous intervals.
