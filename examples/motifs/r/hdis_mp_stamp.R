# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example datasets bundled with harbinger
data(examples_motifs)

# Select an ECG time series with annotated anomalies
dataset <- examples_motifs$mitdb102
head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Define Matrix Profile discord model (STOMP)
# - w: subsequence length (window)
# - qtd: number of discords to retrieve
model <- hdis_mp(mode = "stomp", w = 25, qtd = 10)

# Fit the model
  model <- fit(model, dataset$serie)

# Detect discords
  suppressMessages(detection <- detect(model, dataset$serie))

# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))

# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
  
