# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Instantiate utilities
hutils <- harutils()

# Synthetic residual vectors used to test the new utility functions directly
set.seed(123)
res_grubbs <- c(rnorm(40, mean = 0, sd = 0.15), 1.8, -1.7)
res_sequence <- c(rnorm(30, mean = 0, sd = 0.20), 1.7, 1.9, 1.8, 0.1)

# Load a simple anomaly dataset and plot it
data(examples_anomalies)
dataset <- examples_anomalies$simple
har_plot(harbinger(), dataset$serie)

# Direct test of the Grubbs filter criterion on a synthetic residual vector
gidx <- hutils$har_filter_grubbs(res_grubbs)
print(gidx)
print(attr(gidx, "threshold"))
print(attr(gidx, "score")[gidx])

# Direct test of reference-distribution candidate selection
candidate_idx <- 31:33
flags_refdist <- hutils$har_candidate_selection_referencedistribution(
  candidate_idx,
  res_sequence,
  history_size = 30,
  distribution = "gaussian",
  sigma_level = 3
)
print(which(flags_refdist))

# Baseline: ARIMA with default deviation measure (L2) and filter criterion (Gaussian 3-sigma)
model <- hanr_arima()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Use the boxplot/IQR filter criterion instead of Gaussian
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_boxplot
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Use the ratio-based filter criterion to emphasize relative deviation
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_ratio
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Use the Grubbs filter criterion to iteratively isolate the most extreme residuals
model <- hanr_arima()
model$har_outliers <- hutils$har_filter_grubbs
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
threshold_grubbs <- attr(detection, "threshold")
threshold_grubbs <- threshold_grubbs[is.finite(threshold_grubbs)]
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = threshold_grubbs)

# Change the deviation measure to L1 (absolute deviation)
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# L1 deviation measure + boxplot/IQR filter criterion
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_boxplot
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# L1 deviation measure + ratio-based filter criterion
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_ratio
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Candidate selection: keep only the highest-magnitude index in contiguous runs
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_boxplot
model$har_outliers_check <- hutils$har_candidate_selection_highgroup
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))

# Candidate selection: evaluate each candidate against the distribution
# estimated from the 30 observations that precede the candidate run
model <- hanr_arima()
model$har_distance <- hutils$har_deviation_l1
model$har_outliers <- hutils$har_filter_boxplot
model$har_outliers_check <- hutils$har_candidate_selection_referencedistribution
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
