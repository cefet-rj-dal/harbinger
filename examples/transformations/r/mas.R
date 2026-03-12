# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(harbinger)

# Load example change-point datasets
data(examples_changepoints)

# Select a simple change-point dataset
dataset <- examples_changepoints$simple
head(dataset)

# Plot the original time series
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Compute smoothers with two different window sizes
ma_5 <- mas(dataset$serie, order = 5)
ma_15 <- mas(dataset$serie, order = 15)

# Inspect the first smoothed values
head(ma_5)
head(ma_15)

# Plot the 5-point moving average
har_plot(
  harbinger(),
  as.numeric(ma_5),
  event = dataset$event[5:length(dataset$event)]
)

# Plot the 15-point moving average
har_plot(
  harbinger(),
  as.numeric(ma_15),
  event = dataset$event[15:length(dataset$event)]
)
