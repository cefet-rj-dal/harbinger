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

# Plot the time series to visualize regimes
har_plot(harbinger(), dataset$serie)

# Configure BinSeg; Q is the max number of change points to search
model <- hcp_binseg(Q = 10)

# Fit the detector (keeps parameters on object)
model <- fit(model, dataset$serie)

# Run detection over the series
detection <- detect(model, dataset$serie)

# Show detected change-point indices
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot detections and ground truth
har_plot(model, dataset$serie, detection, dataset$event)
