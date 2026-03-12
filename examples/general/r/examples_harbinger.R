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
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: global temperature (yearly)
dataset <- examples_harbinger$global_temperature_yearly
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: global temperature (monthly)
dataset <- examples_harbinger$global_temperature_monthly
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: multidimensional time series
dataset <- examples_harbinger$multidimensional
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


model <- fit(model, dataset$x)
detection <- detect(model, dataset$x)
har_plot(model, dataset$x, detection, dataset$event)


# Example: Seattle weekly temperature time series
dataset <- examples_harbinger$seattle_week
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# Example: Seattle daily temperature time series
dataset <- examples_harbinger$seattle_daily
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)

