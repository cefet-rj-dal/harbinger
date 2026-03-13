# Transformation Examples

These notebooks show how a series can be simplified or re-encoded before downstream analysis. The point is not only to demonstrate the functions, but to help the reader see when a transformation changes the kind of pattern that becomes easier to detect.

This folder is easier to appreciate after the reader has already seen a raw series and a first detector. The grouping below follows that learning logic: start with smoothing, which is intuitive to visualize, and then move to symbolic representations, which are more abstract but very useful for sequence analysis.

## Smoothing

Smoothing is a good entry point because it shows immediately how preprocessing can change what stands out in a plot.

- [01-smoothing-mas.md](/examples/transformations/01-smoothing-mas.md) - `mas()`: moving-average smoothing for reducing local variation.

## Symbolic Representations

These examples are worth reading after smoothing because they shift the reader from numeric intuition to sequence abstraction.

- [02-symbolic-trans_sax.md](/examples/transformations/02-symbolic-trans_sax.md) - `trans_sax()`: discretize the series into a compact symbolic alphabet.
- [03-symbolic-trans_xsax.md](/examples/transformations/03-symbolic-trans_xsax.md) - `trans_xsax()`: use a richer alphabet for finer symbolic resolution.
