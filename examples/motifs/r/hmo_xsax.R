# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example motif datasets
data(examples_motifs)

# Select the simple motif dataset
dataset <- examples_motifs$simple
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure XSAX motif discovery (alphabet=37, word=3, min occurrences=3)
model <- hmo_xsax(37, 3, 3)

# Fit the detector (learns binning thresholds)
model <- fit(model, dataset$serie)

# Run motif discovery
detection <- detect(model, dataset$serie)

# Show detected motif starts
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot motifs and ground truth
har_plot(model, dataset$serie, detection, dataset$event)
