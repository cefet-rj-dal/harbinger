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
- [general](/examples/general/README.md) - high-level tours ordered as orientation, utilities, and evaluation notebooks
- [custom](/examples/custom/README.md) - extension-oriented notebooks grouped by the type of component being implemented
- [data](/examples/data/README.md) - dataset-orientation notebooks grouped into general benchmark archives and domain-specific collections
- [transformations](/examples/transformations/README.md) - smoothing and symbolic transformations presented from simpler preprocessing to richer symbolic encodings
- [anomalies](/examples/anomalies/README.md) - anomaly detection grouped by learning objective: baseline intuition, residual models, supervised classifiers, clustering, ensembles, autoencoders, and multivariate analysis
- [change_point](/examples/change_point/README.md) - change-point detection ordered from single-break intuition to multiple breaks, structural change, and volatility-focused methods
- [motifs](/examples/motifs/README.md) - motif and discord discovery grouped into Matrix Profile methods, symbolic methods, and discord-specific analyses
