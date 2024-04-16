library(daltoolbox)
library(ggplot2)
set.seed(6)

# Loading the example database
data(har_examples)

#Using example 1
dataset <- har_examples$example1
cut_index <- 60
srange <- cut_index:row.names(dataset)[nrow(dataset)]
drift_size <- nrow(dataset[srange,])
dataset[srange, 'serie'] <- dataset[srange, 'serie'] + rnorm(drift_size, mean=0, sd=0.5)
head(dataset)

plot(x=row.names(dataset), y=dataset$serie, type='l')

# Setting up time series regression model
model <- hanct_kmeans()

# Fitting the model
model <- fit(model, dataset$serie)

# Making detection using hanr_ml
detection <- detect(model, dataset$serie)

# Filtering detected events
print(detection[(detection$event),])

# Drift test

drift_evaluation <- data.frame(!(detection$event == dataset$event)) * 1
model <- fit(hcd_ddm(min_instances=10, out_control_level = 2, warning_level=0), drift_evaluation)
detection_drift <- detect(model, drift_evaluation)

grf <- har_plot(model, dataset$serie, detection_drift)
grf <- grf + ggplot2::ylab("value")
grf <- grf

plot(grf)
