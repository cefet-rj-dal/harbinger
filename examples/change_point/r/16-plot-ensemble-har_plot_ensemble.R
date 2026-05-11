# Install Harbinger (if needed)
# install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger)

# Load example change-point datasets
data(examples_changepoints)

# Select the simple dataset
dataset <- examples_changepoints$simple

# Configure the same stronger ensemble used in the previous notebook
model <- har_ensemble_fuzzy(
  hcp_scp(sw = 30),
  hcp_chow(),
  hcp_cf_arima(sw_size = 10)
)

# Fit the ensemble and run detection
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie, time_tolerance = 8, use_nms = TRUE)

# Plot the fused ensemble score
har_ensemble_plot(detection, dataset$serie)

# Plot the contribution of each base detector
har_ensemble_plot_models(detection, dataset$serie)
