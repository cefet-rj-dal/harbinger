# Harbinger Examples

This directory contains the source R Markdown notebooks used to generate the material under `/examples/`. The collection is organized to help the reader learn `harbinger` in a sensible order instead of navigating only a flat catalog of methods.

The examples follow the same two entry points presented in the project `README.Rmd`: a guided tutorial track for readers who want a step-by-step introduction, and thematic collections for readers who want to study a specific family of methods.

## Documentation structure

If you are new to `harbinger`, start with the tutorials. If you already know the basic workflow, use the thematic folders below as focused reference tracks. The links point to the rendered Markdown files intended for reading.

### Guided tutorial track
### Guided tutorial track

- [Tutorials](/examples/tutorial/README.md) - a 10-part learning sequence covering first contact with the package, data inspection, plotting, baseline anomaly detection, residual-based detection, evaluation, change points, smoothing, symbolic transformations, and motif analysis.

### Thematic example collections
### Thematic example collections

- [General examples](/examples/general/README.md) - package orientation, utility helpers, and evaluation objects that explain the common structure behind the methods.
- [Dataset examples](/examples/data/README.md) - benchmark archives and domain datasets, organized to help the reader understand the collections before modeling.
- [Transformation examples](/examples/transformations/README.md) - smoothing and symbolic encodings that prepare a series for later anomaly, change-point, or motif analysis.
- [Anomaly examples](/examples/anomalies/README.md) - anomaly detection methods grouped from simple baselines to residual models, supervised learners, clustering, ensembles, autoencoders, and multivariate workflows.
- [Change-point examples](/examples/change_point/README.md) - change-point methods ordered from a first single-break intuition to multiple-break, structural-break, and volatility-oriented techniques.
- [Motif examples](/examples/motifs/README.md) - repeated-pattern and discord analysis grouped into Matrix Profile, symbolic, and discord-oriented studies.
- [Custom examples](/examples/custom/README.md) - extension-oriented notebooks showing how to plug new transformations, detectors, motif methods, and evaluators into Harbinger.

## Documentation design

The examples were revised to be more useful for learning:

- files inside each collection are numbered in a suggested reading order
- category `README` files group examples by subject rather than only by function name
- tutorials and introductory notebooks explain the technique being presented, not only the commands required to run it
