library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple

# Configure and fit the ARIMA-based detector
model <- hanr_arima()
model <- fit(model, dataset$serie)

# Detect anomalies from model residuals
detection <- detect(model, dataset$serie)
head(detection)

# Evaluate against the ground truth
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix

# Plot detections on the original series
har_plot(model, dataset$serie, detection, dataset$event)

# Plot the residual signal used by the detector
har_plot(
  model,
  attr(detection, "res"),
  detection,
  dataset$event,
  yline = attr(detection, "threshold")
)
