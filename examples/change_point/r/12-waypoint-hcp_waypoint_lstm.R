source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
# Install Harbinger and DALToolboxDP (if needed)
# install.packages("harbinger")
# install.packages("daltoolboxdp")

# Load required packages
library(daltoolbox)
library(daltoolboxdp)
library(harbinger)

# Load example change-point datasets
data(examples_changepoints)

# Select the same dataset used in the AMOC example
dataset <- examples_changepoints$complex
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure Waypoint with an LSTM autoencoder
model <- hcp_waypoint(
  input_size = 12,
  encode_size = 4,
  warmup = 60,
  retrain_size = 30,
  buffer_size = 40,
  k_factor = 0.35,
  h_low = 3.5,
  h_high = 6,
  prob_tau = 0.997,
  epochs_init = 100,
  epochs_retrain = 100,
  encoderclass = autoenc_lstm_ed
)

# Fit the detector
set_example_seed()
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

# Plot reconstruction error and the learned decision level
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "tau"))
