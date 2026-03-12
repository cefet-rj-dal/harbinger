---
title: "Transformations — Examples Index"
output: github_document
---

# Transformations — Examples Index

This folder gathers transformation notebooks that prepare, simplify, or re-encode time series before a downstream task such as anomaly detection, change-point analysis, or motif discovery. The focus here is not event detection itself, but how the series representation changes and what each transformation helps reveal.

These examples are especially useful for readers who want to understand the input representation before moving to a detector.

## Suggested reading order

1. start with `mas.md` to see a simple smoothing transformation
2. continue with `trans_sax.md` to understand symbolic approximation
3. finish with `trans_xsax.md` to compare SAX with a higher-resolution symbolic alphabet

## Examples

- [mas.md](/examples/transformations/mas.md) - Simple moving-average smoothing with `mas()`, showing how the window size changes the resulting signal.
- [trans_sax.md](/examples/transformations/trans_sax.md) - SAX transformation, converting a numeric series into a compact symbolic representation.
- [trans_xsax.md](/examples/transformations/trans_xsax.md) - XSAX transformation, using a larger alphabet for a finer symbolic encoding of the same series.
