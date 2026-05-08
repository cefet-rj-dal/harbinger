# Change-Point Examples

This folder collects notebooks that focus on structural change rather than isolated anomaly points. The sequence goes from classical break detection to the new Bayesian and autoencoder-assisted variants.

## Classical Breaks

- [01-single-break-hcp_amoc.md](/examples/change_point/01-single-break-hcp_amoc.md) - `hcp_amoc()`: a single dominant break.
- [02-multiple-breaks-hcp_binseg.md](/examples/change_point/02-multiple-breaks-hcp_binseg.md) - `hcp_binseg()`: recursive segmentation.
- [03-multiple-breaks-hcp_pelt.md](/examples/change_point/03-multiple-breaks-hcp_pelt.md) - `hcp_pelt()`: optimal partitioning with pruning.

## Structural Tests

- [04-structural-break-hcp_chow.md](/examples/change_point/04-structural-break-hcp_chow.md) - `hcp_chow()`: regression-oriented break test.
- [05-structural-break-hcp_gft.md](/examples/change_point/05-structural-break-hcp_gft.md) - `hcp_gft()`: fluctuation test and breakpoint estimation.

## ChangeFinder and Local Windows

- [06-changefinder-hcp_cf_lr.md](/examples/change_point/06-changefinder-hcp_cf_lr.md) - linear-regression ChangeFinder.
- [07-changefinder-hcp_cf_arima.md](/examples/change_point/07-changefinder-hcp_cf_arima.md) - ARIMA ChangeFinder.
- [08-changefinder-hcp_cf_ets.md](/examples/change_point/08-changefinder-hcp_cf_ets.md) - ETS ChangeFinder.
- [09-volatility-hcp_garch.md](/examples/change_point/09-volatility-hcp_garch.md) - volatility regime shifts.
- [10-window-hcp_scp.md](/examples/change_point/10-window-hcp_scp.md) - local-window comparison around a candidate change.

## Adaptive and Bayesian Variants

- [11-waypoint-hcp_waypoint_ed.md](/examples/change_point/11-waypoint-hcp_waypoint_ed.md) - `hcp_waypoint()` with a feed-forward autoencoder.
- [12-waypoint-hcp_waypoint_lstm.md](/examples/change_point/12-waypoint-hcp_waypoint_lstm.md) - `hcp_waypoint()` with an LSTM autoencoder.
- [13-waypoint-hcp_waypoint_conv.md](/examples/change_point/13-waypoint-hcp_waypoint_conv.md) - `hcp_waypoint()` with a convolutional autoencoder.
- [14-bocpd-hcp_bocpd.md](/examples/change_point/14-bocpd-hcp_bocpd.md) - `hcp_bocpd()`: Bayesian online changepoint detection.

## Ensemble Support

- [15-ensemble-fuzzy-har_ensemble_fuzzy.md](/examples/change_point/15-ensemble-fuzzy-har_ensemble_fuzzy.md) - fuzzy score-based ensemble for change-point detectors.
- [16-plot-ensemble-har_plot_ensemble.md](/examples/change_point/16-plot-ensemble-har_plot_ensemble.md) - plotting helpers for fuzzy ensemble outputs.

## Univariate Drift Detectors

- [17-page-hinkley-hcp_page_hinkley.md](/examples/change_point/17-page-hinkley-hcp_page_hinkley.md) - `hcp_page_hinkley()`: univariate Page-Hinkley detector.
- [18-kswin-hcp_kswin.md](/examples/change_point/18-kswin-hcp_kswin.md) - `hcp_kswin()`: univariate KSWIN detector.

