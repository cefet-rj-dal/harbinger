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

# Configure the SAX transformer
model <- trans_sax(alpha = 8)

# Fit and transform the numeric series into symbols
model <- fit(model, dataset$serie)
sax_series <- transform(model, dataset$serie)

# Inspect the first symbolic values
head(sax_series, 20)

# Compare original values with SAX symbols
comparison <- data.frame(
  idx = seq_along(dataset$serie),
  value = dataset$serie,
  sax = sax_series
)
head(comparison, 20)
