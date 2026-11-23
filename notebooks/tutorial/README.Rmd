# Tutorial Track

This section presents `harbinger` as a guided learning path. Instead of starting from isolated detectors, the tutorials begin with the package workflow, then move through data inspection, plotting, baseline methods, evaluation, and only later reach transformations and motif analysis.

The sequence is cumulative. Each notebook introduces one main idea and keeps the code close to that idea, so the reader can understand both the package interface and the analytical reason for each step.

This folder should be read in order. The first notebooks lower the entry barrier, the middle notebooks explain how to inspect and evaluate results, and the last ones broaden the reader's view of what event analysis can include beyond a first anomaly detector.

Recommended reading order:

- [01-first-steps.md](/examples/tutorial/01-first-steps.md) - understand the minimum Harbinger workflow on a labeled anomaly series.
- [02-knowing-your-data.md](/examples/tutorial/02-knowing-your-data.md) - inspect benchmark collections before choosing a method.
- [03-plotting-series.md](/examples/tutorial/03-plotting-series.md) - use `har_plot()` to read univariate and multivariate series.
- [04-first-anomaly-detector.md](/examples/tutorial/04-first-anomaly-detector.md) - start with a simple histogram detector before moving to stronger models.
- [05-model-based-anomaly-detection.md](/examples/tutorial/05-model-based-anomaly-detection.md) - detect anomalies through residuals from an ARIMA model.
- [06-evaluating-detections.md](/examples/tutorial/06-evaluating-detections.md) - compare strict and tolerant evaluation of detections.
- [07-first-change-point-detector.md](/examples/tutorial/07-first-change-point-detector.md) - detect a first structural break with AMOC.
- [08-smoothing-with-mas.md](/examples/tutorial/08-smoothing-with-mas.md) - see how moving averages change the reading of a series.
- [09-symbolic-representation.md](/examples/tutorial/09-symbolic-representation.md) - transform a numeric series into SAX and XSAX codes.
- [10-motifs-and-discords.md](/examples/tutorial/10-motifs-and-discords.md) - close the path with motif-oriented sequence analysis.
