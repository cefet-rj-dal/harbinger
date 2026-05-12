source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example datasets bundled with harbinger
data(examples_changepoints)

# Select the same labeled series used in the AMOC example
dataset <- examples_changepoints$complex
head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Define the ChangeFinder-LR model
# - sw_size controls the sliding window length
model <- hcp_cf_lr(sw_size = 10)

# Fit the model
set_example_seed()
model <- fit(model, dataset$serie)

# Detect change-points
detection <- detect(model, dataset$serie)

# Show only timestamps flagged as events
print(detection |> dplyr::filter(event == TRUE))

# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
  

# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
