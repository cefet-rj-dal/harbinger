# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example anomaly datasets
data(examples_anomalies)

# Select a simple anomaly dataset
dataset <- examples_anomalies$simple
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure the EMD-based detector
model <- hanr_emd()

# Fit the detector
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected anomaly indices
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)

# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
