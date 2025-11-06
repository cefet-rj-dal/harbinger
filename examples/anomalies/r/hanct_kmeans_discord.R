# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example datasets bundled with harbinger
data(examples_anomalies)

# Use the sequence time series (labeled)
dataset <- examples_anomalies$sequence
head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Define k-means discord detector (k controls number of clusters)
  model <- hanct_kmeans(3)

# Fit the model
  model <- fit(model, dataset$serie)

# Detect discords using k-means distances
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
  
