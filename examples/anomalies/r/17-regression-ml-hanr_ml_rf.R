# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 
library(tspredit)

# Load example datasets bundled with harbinger
data(examples_anomalies)

# Select a simple synthetic time series with labeled anomalies
dataset <- examples_anomalies$simple
head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Define RF-based regressor for anomaly detection (hanr_ml + ts_rf)
# - input_size: window length; nodesize/ntree: RF hyperparameters
  model <- hanr_ml(ts_rf(ts_norm_gminmax(), input_size=4, nodesize=1, ntree=20))

# Fit the model
  model <- fit(model, dataset$serie)

# Detect anomalies (compute residuals and events)
  detection <- detect(model, dataset$serie)

# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))

# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
  

# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
  
