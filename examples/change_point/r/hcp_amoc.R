# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example change-point datasets
data(examples_changepoints)

# Select a dataset ("complex" contains multiple regimes)
dataset <- examples_changepoints$complex
head(dataset)

# Plot the time series to visualize regime changes
har_plot(harbinger(), dataset$serie)

# Configure the AMOC change-point detector (single change)
model <- hcp_amoc()

# Fit the detector (no training required, keeps parameters on object)
model <- fit(model, dataset$serie)

# Run detection over the full series
detection <- detect(model, dataset$serie)

# Show detected change-point indices
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against the labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot detections and ground truth on top of the series
har_plot(model, dataset$serie, detection, dataset$event)
