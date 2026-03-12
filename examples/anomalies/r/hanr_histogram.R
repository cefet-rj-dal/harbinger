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
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Configure the histogram-based anomaly detector
# The density threshold controls how rare a bin must be to trigger an anomaly
model <- hanr_histogram(density_threshold = 0.05)

# Fit is a no-op here, but keeping the same workflow is useful for comparison
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show the detected anomaly indices
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against the labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot detections and ground truth on the same series
har_plot(model, dataset$serie, detection, dataset$event)
