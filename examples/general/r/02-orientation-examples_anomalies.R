source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example anomaly datasets and create a base object
data(examples_anomalies)
model <- harbinger()

# Simple anomalies: isolated spikes
dataset <- examples_anomalies$simple
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Contextual anomalies: depend on local context
dataset <- examples_anomalies$contextual
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Trend with anomalies
dataset <- examples_anomalies$trend
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Multiple anomalies
dataset <- examples_anomalies$multiple
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Anomalous repeating sequences
dataset <- examples_anomalies$sequence
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Train/Test split
dataset <- examples_anomalies$tt
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Train/Test warped
dataset <- examples_anomalies$tt_warped
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Increasing amplitude over time
dataset <- examples_anomalies$increasing_amplitude
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Decreasing amplitude over time
dataset <- examples_anomalies$decreasing_amplitude
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Volatile variance
dataset <- examples_anomalies$volatile
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)

