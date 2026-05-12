source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load change-point example datasets and create a base object
data(examples_changepoints)
model <- harbinger()

# Simple change point
dataset <- examples_changepoints$simple
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Sinusoidal pattern with regime shift
dataset <- examples_changepoints$sinusoidal
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Incremental trend changes
dataset <- examples_changepoints$incremental
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Abrupt level shift
dataset <- examples_changepoints$abrupt
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Volatility (variance) change
dataset <- examples_changepoints$volatility
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Increasing amplitude
dataset <- examples_changepoints$increasing_amplitude
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Complex multi-regime series
dataset <- examples_changepoints$complex
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)

