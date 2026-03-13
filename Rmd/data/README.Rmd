# Dataset Examples

This folder introduces the collections distributed through the `united` integration. Its purpose is practical: help the reader understand what each benchmark contains before using it in anomaly, change-point, or motif experiments.

Many readers want to jump directly to a model, but that usually leads to weak choices. These notebooks are grouped to encourage the opposite path: first understand the type of collection you are dealing with, then decide which family of techniques makes sense for it.

The sequence starts with broad benchmark archives and then moves to domain datasets with their own signal structure and interpretation.

## Benchmark Archives

These collections are useful when the goal is to compare methods on widely used reference datasets.

- [01-benchmarks-yahoo_benchmarks.md](/examples/data/01-benchmarks-yahoo_benchmarks.md) - Yahoo Webscope S5 benchmark groups and their labeled anomaly series.
- [02-benchmarks-nab.md](/examples/data/02-benchmarks-nab.md) - Numenta Anomaly Benchmark collections and their event-oriented labeling style.
- [03-benchmarks-ucr.md](/examples/data/03-benchmarks-ucr.md) - UCR Anomaly Archive examples for subsequence-oriented anomaly studies.

## Domain Collections

After the benchmark archives, these examples show datasets whose signals come from more specific application contexts and therefore demand more careful interpretation.

- [04-domain-mit_bih.md](/examples/data/04-domain-mit_bih.md) - MIT-BIH arrhythmia signals and ECG-oriented inspection.
- [05-domain-oil_3w.md](/examples/data/05-domain-oil_3w.md) - 3W oil-well datasets with multivariate sensor readings.
- [06-domain-gecco.md](/examples/data/06-domain-gecco.md) - GECCO water-quality series for real-world anomaly analysis.
