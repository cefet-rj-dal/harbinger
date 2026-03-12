# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example datasets bundled with harbinger
data(examples_motifs)

# Select a simple example time series
dataset <- examples_motifs$simple
head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Define Matrix Profile (VALMOD) motif model
# - second arg: min subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("valmod", 4, 3)

# Fit the model
  model <- fit(model, dataset$serie)

# Detect motifs
  detection <- detect(model, dataset$serie)

# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))

# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
  
