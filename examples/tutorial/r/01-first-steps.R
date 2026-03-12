# Install Harbinger (if needed)
# install.packages("harbinger")

# Load the package
library(harbinger)

# Load a small labeled anomaly dataset distributed with the package
data(examples_anomalies)
dataset <- examples_anomalies$simple
head(dataset)

# Plot the series with the known labeled events
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Create the default Harbinger detector
model <- harbinger()

# Run detection on the series
detection <- detect(model, dataset$serie)
head(detection)

# Plot detections against the labeled events
har_plot(model, dataset$serie, detection, dataset$event)
