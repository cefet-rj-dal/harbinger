# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load example anomaly datasets
data(examples_anomalies)

# Select a simple anomaly dataset
dataset <- examples_anomalies$simple
head(dataset)

# Plot the raw time series
har_plot(harbinger(), dataset$serie)

# Configure a simple MLP regressor-based anomaly detector
model <- hanr_ml(ts_mlp(ts_norm_gminmax(), input_size = 5, size = 3, decay = 0))

# Fit the detector
model <- fit(model, dataset$serie)

# Run detection 
detection <- detect(model, dataset$serie)

# Inspect detected anomaly indices
print(detection |> dplyr::filter(event == TRUE))

# Hard evaluation
evaluation <- evaluate(model, detection$event, dataset$event, evaluation = har_eval())
print(evaluation$confMatrix)

# Soft evaluation (SoftED) with tolerance window sw_size = 5
result <- evaluate(model, detection$event, dataset$event, evaluation = har_eval_soft(sw_size = 5))
print(result$confMatrix)

# Evaluation can also be performed directly without a model object
result <- evaluate(har_eval_soft(sw_size = 5), detection$event, dataset$event)
print(result$confMatrix)
