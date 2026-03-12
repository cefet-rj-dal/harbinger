library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Configure a simple baseline detector
model <- hanr_histogram(density_threshold = 0.05)
detection <- detect(model, dataset$serie)
head(detection)

# Compare detections with the labeled events
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix

# Plot detections and labels together
har_plot(model, dataset$serie, detection, dataset$event)
