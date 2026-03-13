# General Examples

This folder is the quickest package tour. It is the best place to start after the tutorials, or before them if the reader wants a compact view of what `harbinger` covers.

Instead of presenting unrelated files, the material is grouped around three questions that usually appear first when someone approaches the package: what problems Harbinger solves, which helper functions support the workflow, and how the final detections should be evaluated.

If the reader wants orientation first and detail later, this is the right folder to read from top to bottom.

## Orientation

Start here if you want to understand the vocabulary of the package before studying any specific method family.

- [01-orientation-examples_harbinger.md](/examples/general/01-orientation-examples_harbinger.md) - broad package overview using representative datasets and tasks.
- [02-orientation-examples_anomalies.md](/examples/general/02-orientation-examples_anomalies.md) - what anomaly detection means in the package and how the examples are organized.
- [03-orientation-examples_changepoints.md](/examples/general/03-orientation-examples_changepoints.md) - change-point problems, typical outputs, and package scope.
- [04-orientation-examples_motifs.md](/examples/general/04-orientation-examples_motifs.md) - motifs, discords, and sequence-oriented workflows.

## Utilities

After the package tour, these examples show helper functions that often appear around the main models and make the outputs easier to interpret.

- [05-utilities-examples_harutils_distance.md](/examples/general/05-utilities-examples_harutils_distance.md) - helper functions for distance summaries over residual or subsequence signals.
- [06-utilities-examples_harutils_outliers.md](/examples/general/06-utilities-examples_harutils_outliers.md) - helper functions for thresholding, grouping, and anomaly post-processing.

## Evaluation

Finish with evaluation, because this is where the reader learns how to judge whether a detector found the right event and how strict that judgment should be.

- [07-evaluation-har_eval.md](/examples/general/07-evaluation-har_eval.md) - strict event evaluation with confusion-matrix style metrics.
- [08-evaluation-har_eval_soft.md](/examples/general/08-evaluation-har_eval_soft.md) - tolerant evaluation when small temporal misalignment should not count as a full error.
