# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 
library(ggplot2)

# Load a multivariate example and define event labels (for demo)
data("examples_harbinger")
dataset <- examples_harbinger$multidimensional
dataset$event <- FALSE
dataset$event[c(101,128,167)] <- TRUE

head(dataset)

# Plot the target series
har_plot(harbinger(), dataset$serie)

# Plot the second dimension
har_plot(harbinger(), dataset$x)

# Fit the PCA detector on the first two columns and run detection
model <- fit(hmu_pca(), dataset[,1:2])
detection <- detect(model, dataset[,1:2])

# Plot detections on the target series
grf <- har_plot(model, dataset$serie, detection, dataset$event)
grf <- grf + ylab("serie")


# Plot detections on the second dimension
grf <- har_plot(model, dataset$x, detection, dataset$event)
grf <- grf + ylab("x")


# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
  
