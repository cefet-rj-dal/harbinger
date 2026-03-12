# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example anomaly datasets
data(examples_anomalies)

# Select the train/test dataset
dataset <- examples_anomalies$tt

head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Split into train/test and normalize features
train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)

# Configure NB classifier
model <- hanc_ml(cla_nb("event", c("FALSE", "TRUE")))

# Fit on training data, evaluate on train
model <- fit(model, train_n)
detection <- detect(model, train_n)
print(detection |> dplyr::filter(event == TRUE))
evaluation <- evaluate(model, detection$event, as.logical(train_n$event))
print(evaluation$confMatrix)

# Plot training detections
har_plot(model, train_n$serie, detection, as.logical(train_n$event))

# Prepare normalized test set
test_n <- transform(norm, test)

# Detect and evaluate on test
detection <- detect(model, test_n)
print(detection |> dplyr::filter(event == TRUE))
evaluation <- evaluate(model, detection$event, as.logical(test_n$event))
print(evaluation$confMatrix)

# Plot test detections
har_plot(model, test_n$serie, detection, as.logical(test_n$event))

# Plot residual magnitude and decision threshold
har_plot(model, attr(detection, "res"), detection, test_n$event, yline = attr(detection, "threshold"))
