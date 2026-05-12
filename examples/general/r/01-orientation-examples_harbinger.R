source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))
# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example datasets bundled with harbinger
data(examples_harbinger)
model <- harbinger()

# Example: nonstationarity time series
dataset <- examples_harbinger$nonstationarity
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: global temperature (yearly)
dataset <- examples_harbinger$global_temperature_yearly
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: global temperature (monthly)
dataset <- examples_harbinger$global_temperature_monthly
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: multidimensional time series
dataset <- examples_harbinger$multidimensional
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


set_example_seed()
model <- fit(model, dataset$x)
detection <- detect(model, dataset$x)
har_plot(model, dataset$x, detection, dataset$event)


# Example: Seattle weekly temperature time series
dataset <- examples_harbinger$seattle_week
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: Seattle daily temperature time series
dataset <- examples_harbinger$seattle_daily
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)

