# Install Harbinger and ocp (if needed)
# install.packages("harbinger")
# install.packages("ocp")

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

# Configure BOCPD with a Gaussian observation model
model <- hcp_bocpd(
  hazard = 100,
  dist = "gaussian",
  threshold = 0.5
)

if (requireNamespace("ocp", quietly = TRUE)) {
  # Fit the detector
  model <- fit(model, dataset$serie)

  # Run detection
  detection <- detect(model, dataset$serie)

  # Show detected change points
  print(detection |> dplyr::filter(event == TRUE))
} else {
  message("The 'ocp' package is not installed, so this example is skipped.")
}

if (exists("detection")) {
  # Evaluate detections against labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
}

if (exists("detection")) {
  # Plot detections vs. ground truth
  har_plot(model, dataset$serie, detection, dataset$event)
}

if (exists("detection")) {
  # Plot normalized changepoint evidence and the decision threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = model$threshold)
}
