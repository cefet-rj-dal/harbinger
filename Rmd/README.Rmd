---
title: "Harbinger Examples"
output: github_document
---

# Harbinger Examples

This directory stores the source `.Rmd` notebooks used to generate the Markdown material under `/examples/`. The files here are the editable sources; the rendered tutorials are expected to live in `/examples/` after the generation step.

Use this index as a didactic map of the example collection. Each section below points to the generated Markdown destination and explains what a reader should expect to learn in that group of examples.

## Suggested reading order

1. start with `tutorial` for the numbered guided path
2. continue with `general` for a compact package tour and the evaluation utilities
3. visit `data` if you want to understand the benchmark datasets before modeling
4. visit `transformations` to see how the series can be smoothed or symbolized before analysis
5. move to `anomalies` or `change_point` when you are ready to run event-detection workflows
6. visit `custom` when you want to learn how to extend the framework with your own components
7. finish with `motifs` for repeated-pattern and discord discovery examples

## Directories

- [tutorial](/examples/tutorial/README.md) - a guided learning path that connects package basics, data understanding, transformations, event detection, evaluation, and motif-oriented tasks
- [general](/examples/general/README.md) - high-level tours, utility examples, and hard or soft evaluation notebooks
- [custom](/examples/custom/README.md) - extension-oriented notebooks showing how to implement custom detectors, transformations, and evaluation rules on top of the Harbinger contracts
- [data](/examples/data/README.md) - dataset-orientation notebooks showing how to load the full benchmark collections with `loadfulldata()`, count the available series, classify them as univariate or multivariate, and inspect the first signal with `har_plot()`
- [transformations](/examples/transformations/README.md) - smoothing and symbolic transformations such as `mas()`, `trans_sax()`, and `trans_xsax()` that prepare series for downstream analysis
- [anomalies](/examples/anomalies/README.md) - anomaly detection across multiple families: regression residuals, clustering and discord methods, supervised classifiers, autoencoders, ensembles, and multivariate workflows
- [change_point](/examples/change_point/README.md) - change-point detection for single breaks, multiple breaks, structural changes, and volatility shifts
- [motifs](/examples/motifs/README.md) - motif and discord discovery via Matrix Profile and symbolic approaches such as SAX and XSAX
