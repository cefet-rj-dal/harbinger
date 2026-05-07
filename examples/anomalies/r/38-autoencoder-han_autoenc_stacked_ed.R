# Load required packages
library(daltoolbox)
library(harbinger) 
library(daltoolboxdp)
python_available <- requireNamespace("reticulate", quietly = TRUE) && reticulate::py_available()
knitr::opts_chunk$set(eval = python_available)

# Load example datasets bundled with harbinger
data(examples_anomalies)

# Select a simple synthetic time series with labeled anomalies
dataset <- examples_anomalies$simple
head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Define stacked autoencoder-based detector (autoenc_stacked_ed)
  model <- han_autoencoder(3, 2, autoenc_stacked_ed, epochs = 100)

# Fit the model
  model <- fit(model, dataset$serie)

# Detect anomalies (reconstruction error -> events)
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
