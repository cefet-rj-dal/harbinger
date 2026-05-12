source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))
# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Instantiate utilities
hutils <- harutils()

# Load a simple anomaly dataset and plot it
data(examples_anomalies)
dataset <- examples_anomalies$simple
har_plot(harbinger(), dataset$serie)

# Baseline configuration.
# Objective: provide a simple global rule for residual screening.
# Property: the default Gaussian filter uses a mean ± 3*sd logic on the
# residual magnitudes, so it works as a strong baseline when the residual
# scale is reasonably stable.
model <- hanr_arima()
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Boxplot/IQR filter criterion.
# Objective: replace the Gaussian assumption by a robust dispersion rule.
# Property: the IQR cutoff is less tied to normality and often behaves better
# when the residual distribution is asymmetric or already contains a few
# influential extremes.
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_boxplot
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# MAD filter criterion.
# Objective: use a robust center/scale estimate instead of mean and standard
# deviation.
# Property: the median-plus-MAD cutoff remains stable even when a few extreme
# residuals are already present, which makes it a strong alternative when the
# residual distribution is heavy-tailed or visibly contaminated.
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_mad
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Ratio-based filter criterion.
# Objective: evaluate residuals in relative rather than purely absolute terms.
# Property: this approach rescales the residuals before applying the cutoff,
# which can be useful when the analyst wants the decision to reflect deviation
# proportionally to the observed residual range.
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_ratio
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Grubbs filter criterion.
# Objective: isolate truly extreme residuals through an iterative statistical
# test instead of a single global cutoff.
# Property: it tends to be more selective and is especially useful when the
# goal is to retain only a few very strong extremes. Its threshold is plotted
# as the empirical boundary of the points that were actually retained.
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_grubbs
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
threshold_grubbs <- attr(detection, "threshold")
threshold_grubbs <- threshold_grubbs[is.finite(threshold_grubbs)]
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = threshold_grubbs)

# L1 deviation measure.
# Objective: change how residual magnitude is summarized before filtering.
# Property: L1 (absolute deviation) is usually more robust than L2 because it
# reduces the influence of very large residual peaks on the scale of the score.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Huber deviation measure.
# Objective: keep some of the peak sensitivity of L2 without letting a few
# extremes dominate the score as strongly.
# Property: Huber behaves quadratically near zero and linearly in the tails,
# so it often acts as a compromise between L2 emphasis and L1 robustness.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_huber
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# L1 deviation + boxplot/IQR filter.
# Objective: combine a robust deviation summary with a robust cutoff rule.
# Property: this is a natural configuration when the analyst wants to reduce
# sensitivity both in the score construction and in the candidate filter.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_boxplot
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Huber deviation + MAD filter.
# Objective: combine a compromise deviation score with a robust threshold rule.
# Property: this configuration is useful when the analyst wants the score to
# still react to moderate residual growth while keeping the cutoff itself
# resistant to a few extreme observations.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_huber
model$har_outliers <- hutils$har_filter_mad
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# L1 deviation + ratio filter.
# Objective: keep the more robust L1 score while shifting the cutoff to a
# relative scale.
# Property: this combination is useful when absolute residual magnitude alone
# is not the most informative way to decide what should be considered extreme.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_ratio
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Highgroup candidate selection.
# Objective: collapse a contiguous run of candidates into a single point.
# Property: the representative point is the one with the highest residual
# magnitude, which makes this strategy appropriate when the analyst wants one
# punctual marker per event and prefers the local peak over the first crossing.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_boxplot
model$har_outliers_check <- hutils$har_candidate_selection_highgroup
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Reference-distribution candidate selection.
# Objective: re-evaluate each candidate in a contiguous run against the local
# regime that existed before the run started.
# Property: unlike firstgroup/highgroup, this rule does not force the block to
# become a single point. If several adjacent candidates are all individually
# incompatible with the previous 30 observations, the sequence is preserved
# naturally in the final detection.
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_boxplot
model$har_outliers_check <- hutils$har_candidate_selection_referencedistribution
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
