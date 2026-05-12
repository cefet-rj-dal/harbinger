source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example change-point datasets
data(examples_changepoints)

# Select the same dataset used in the AMOC example
dataset <- examples_changepoints$complex
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure SCP (sw controls window; here 30)
model <- hcp_scp(sw=30)

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

# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
