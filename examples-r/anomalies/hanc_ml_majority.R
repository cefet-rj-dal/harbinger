# Install Harbinger (only once, if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example datasets bundled with harbinger
data(examples_anomalies)

# Use the "tt" time series (labeled)
dataset <- examples_anomalies$tt

head(dataset)

# Plot the time series
har_plot(harbinger(), dataset$serie)

# Data preprocessing: split and scale


train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)

# Define Majority Classifier for events (hanc_ml + cla_majority)
model <- hanc_ml(cla_majority("event", c("FALSE", "TRUE")))

# Fit the model on training data
model <- fit(model, train_n)
detection <- detect(model, train_n)
print(detection |> dplyr::filter(event==TRUE))
# Evaluate training performance
evaluation <- evaluate(model, detection$event, as.logical(train_n$event))
print(evaluation$confMatrix)

# Plot training detections
  har_plot(model, train_n$serie, detection, as.logical(train_n$event))

# Prepare test data (apply same scaler)
  test_n <- transform(norm, test)

# Detect and evaluate on test data
  detection <- detect(model, test_n)

  print(detection |> dplyr::filter(event==TRUE))

  evaluation <- evaluate(model, detection$event, as.logical(test_n$event))
  print(evaluation$confMatrix)

# Plot test detections
  har_plot(model, test_n$serie, detection, as.logical(test_n$event))

# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, test_n$event, yline = attr(detection, "threshold"))
