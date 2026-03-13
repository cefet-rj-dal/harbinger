# Change-Point Examples

This folder introduces methods that search for structural changes rather than isolated anomalous points. The examples are organized from the simplest case, one dominant break, to richer segmentation and volatility-oriented strategies.

The progression matters: AMOC is a good first notebook, while the later methods make more sense once the reader already understands what a labeled change point looks like in the plots. The groups below were arranged to move from intuition to more specialized analytical perspectives.

## Single Break

This is the best starting point because it teaches the core idea of regime transition with the least cognitive load.

- [01-single-break-hcp_amoc.md](/examples/change_point/01-single-break-hcp_amoc.md) - `hcp_amoc()`: first example for a single dominant change point.

## Multiple Breaks

Once one break is clear, these examples show how the same reasoning extends to several structural changes in the same series.

- [02-multiple-breaks-hcp_binseg.md](/examples/change_point/02-multiple-breaks-hcp_binseg.md) - `hcp_binseg()`: recursive segmentation for multiple changes.
- [03-multiple-breaks-hcp_pelt.md](/examples/change_point/03-multiple-breaks-hcp_pelt.md) - `hcp_pelt()`: optimal partitioning with pruning.

## Structural Tests

These notebooks are useful for readers who want to connect change-point detection with more classical statistical testing ideas.

- [04-structural-break-hcp_chow.md](/examples/change_point/04-structural-break-hcp_chow.md) - `hcp_chow()`: regression-oriented structural break test.
- [05-structural-break-hcp_gft.md](/examples/change_point/05-structural-break-hcp_gft.md) - `hcp_gft()`: fluctuation tests and breakpoint estimation.

## ChangeFinder Variants

After the classical methods, this group shows a family that scores changes through predictive surprise over time.

- [06-changefinder-hcp_cf_lr.md](/examples/change_point/06-changefinder-hcp_cf_lr.md) - ChangeFinder with linear regression.
- [07-changefinder-hcp_cf_arima.md](/examples/change_point/07-changefinder-hcp_cf_arima.md) - ChangeFinder with ARIMA.
- [08-changefinder-hcp_cf_ets.md](/examples/change_point/08-changefinder-hcp_cf_ets.md) - ChangeFinder with ETS.

## Volatility and Local Windows

These are good final readings because they focus on more specific views of change, such as variance shifts or local window contrasts.

- [09-volatility-hcp_garch.md](/examples/change_point/09-volatility-hcp_garch.md) - `hcp_garch()`: volatility shifts as structural changes.
- [10-window-hcp_scp.md](/examples/change_point/10-window-hcp_scp.md) - `hcp_scp()`: local-window comparison around candidate changes.
