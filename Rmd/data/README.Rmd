---
title: "Datasets — Examples Index"
output: github_document
---

# Datasets — Examples Index

This folder introduces the datasets distributed through the `united` integration in Harbinger. The examples focus on data orientation rather than detection: how to load the full dataset with `loadfulldata()`, how many series are available, whether the collection is univariate or multivariate, and how to inspect the first signal with `har_plot()`.

These notebooks are especially useful for readers who want to understand the raw material before choosing a detector.

## Suggested reading order

1. start with `yahoo_benchmarks.md` for simple labeled univariate benchmarks
2. move to `nab.md` and `ucr.md` for anomaly archives widely used in the literature
3. use `mit_bih.md` and `oil_3w.md` when you want biomedical or multivariate industrial signals
4. read `gecco.md` for the water-quality benchmark

## Examples

- [gecco.md](/examples/data/gecco.md) - GECCO water-quality dataset, loaded with `loadfulldata()` and summarized before plotting the first available signal.
- [mit_bih.md](/examples/data/mit_bih.md) - MIT-BIH Arrhythmia collections, showing how to inspect the ECG leads distributed as separate dataset objects.
- [nab.md](/examples/data/nab.md) - Numenta Anomaly Benchmark datasets, with one loading-and-inspection example per NAB object.
- [oil_3w.md](/examples/data/oil_3w.md) - 3W oil-well datasets, emphasizing the multivariate structure and plotting the first sensor column.
- [ucr.md](/examples/data/ucr.md) - UCR Anomaly Archive datasets, loaded and summarized through the same workflow.
- [yahoo_benchmarks.md](/examples/data/yahoo_benchmarks.md) - Yahoo Webscope S5 benchmark objects A1 to A4, with full-data loading and quick structural inspection.
