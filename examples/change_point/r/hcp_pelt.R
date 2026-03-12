# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example change-point datasets
data(examples_changepoints)

# Select the simple dataset
dataset <- examples_changepoints$simple
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure the PELT detector
model <- hcp_pelt()

# Fit the detector (no training required)
model <- fit(model, dataset$serie)

# Run detection
detection <- detect(model, dataset$serie)

# Show detected change points
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
