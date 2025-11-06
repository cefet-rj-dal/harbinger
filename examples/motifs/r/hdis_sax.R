# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example motif/discord datasets
data(examples_motifs)

# Select an ECG sample (mitdb102)
dataset <- examples_motifs$mitdb102
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure SAX-based discord discovery (alphabet=26, word=25)
model <- hdis_sax(26, 25)

# Fit the detector (learns binning thresholds)
model <- fit(model, dataset$serie)

# Run discord discovery
detection <- detect(model, dataset$serie)

# Show detected discord starts
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# Plot discords and ground truth
har_plot(model, dataset$serie, detection, dataset$event)
