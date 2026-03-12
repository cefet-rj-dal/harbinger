# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger)

# Load example motif datasets
data(examples_motifs)

# Select a simple motif dataset
dataset <- examples_motifs$simple
head(dataset)

# Plot the original time series
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Configure the XSAX transformer
model <- trans_xsax(alpha = 16)

# Fit and transform the numeric series into an extended symbolic representation
model <- fit(model, dataset$serie)
xsax_series <- transform(model, dataset$serie)

# Inspect the first symbolic values
head(xsax_series, 20)

# Compare original values with XSAX symbols
comparison <- data.frame(
  idx = seq_along(dataset$serie),
  value = dataset$serie,
  xsax = xsax_series
)
head(comparison, 20)
