library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple
head(dataset)

# Plot the original series with the known change point
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Configure and run the AMOC detector
model <- hcp_amoc()
detection <- detect(model, dataset$serie)
detection

# Plot detections against the labeled event
har_plot(model, dataset$serie, detection, dataset$event)
