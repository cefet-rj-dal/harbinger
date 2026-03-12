---
title: "Tutorials — Guided Learning Path"
output: github_document
---

# Tutorials — Guided Learning Path

This folder organizes a step-by-step tutorial path for readers who want to learn Harbinger in a progressive way. Instead of jumping directly into isolated examples, the tutorials start from the package workflow, move through data understanding and transformations, and only then reach detection and pattern-discovery tasks.

If you are new to the package, this is the best place to begin.

## Suggested order

1. [01-first-steps.md](/examples/tutorial/01-first-steps.md) - the basic Harbinger workflow on a simple anomaly series
2. [02-knowing-your-data.md](/examples/tutorial/02-knowing-your-data.md) - how to inspect bundled and full datasets before modeling
3. [03-plotting-series.md](/examples/tutorial/03-plotting-series.md) - how to visualize univariate and multivariate series with `har_plot()`
4. [04-first-anomaly-detector.md](/examples/tutorial/04-first-anomaly-detector.md) - a simple histogram-based anomaly detector
5. [05-model-based-anomaly-detection.md](/examples/tutorial/05-model-based-anomaly-detection.md) - ARIMA-based anomaly detection and residual inspection
6. [06-evaluating-detections.md](/examples/tutorial/06-evaluating-detections.md) - hard and soft evaluation of detected events
7. [07-first-change-point-detector.md](/examples/tutorial/07-first-change-point-detector.md) - a first structural-change workflow
8. [08-smoothing-with-mas.md](/examples/tutorial/08-smoothing-with-mas.md) - smoothing as a transformation before analysis
9. [09-symbolic-representation.md](/examples/tutorial/09-symbolic-representation.md) - SAX and XSAX as symbolic transformations
10. [10-motifs-and-discords.md](/examples/tutorial/10-motifs-and-discords.md) - repeated patterns and rare subsequences

## How this path is organized

The sequence mirrors a common analytical workflow:

- understand the package and the data
- visualize the series before modeling
- try simple and interpretable detectors first
- evaluate what the detector found
- expand to change points, transformations, and symbolic or motif-oriented tasks

