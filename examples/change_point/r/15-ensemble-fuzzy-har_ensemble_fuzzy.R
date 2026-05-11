# Install Harbinger (if needed)
# install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger)

# Load example change-point datasets
data(examples_changepoints)

# Select the simple dataset
dataset <- examples_changepoints$simple
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure the fuzzy ensemble with stronger base detectors for this dataset
model <- har_ensemble_fuzzy(
  hcp_scp(sw = 30),
  hcp_chow(),
  hcp_cf_arima(sw_size = 10)
)

# Fit the ensemble
model <- fit(model, dataset$serie)

# Run detection with temporal fuzzification and non-maximum suppression
detection <- detect(model, dataset$serie, time_tolerance = 8, use_nms = TRUE)

# Show detected change points
print(detection[detection$event, ])

# Plot the ensemble score over the series
har_ensemble_plot(detection, dataset$serie)
