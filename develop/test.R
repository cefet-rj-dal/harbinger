library(daltoolbox)
library(harbinger)
library(ggplot2)

set.seed(1)

#loading the example database
data(examples_anomalies)

#Using simple example
dataset <- examples_anomalies$simple
cut_index <- 60
srange <- cut_index:row.names(dataset)[nrow(dataset)]
drift_size <- nrow(dataset[srange,])
dataset[srange, 'serie'] <- dataset[srange, 'serie'] + rnorm(drift_size, mean=0, sd=0.5)
head(dataset)

plot(x=row.names(dataset), y=dataset$serie, type='l')

# setting up time series regression model
model <- hanct_kmeans()

# fitting the model
model <- fit(model, dataset$serie)

# making detection using hact_kmeans
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])

# Drift test

drift_evaluation <- data.frame(!(detection$event == dataset$event)) * 1
drift_evaluation[cut_index:nrow(drift_evaluation),] = 1
model <- fit(hcd_hddm(drift_confidence=10^-30), drift_evaluation)
detection_drift <- detect(model, drift_evaluation)

grf <- har_plot(model, dataset$serie, detection_drift)
grf <- grf + ylab("value")
grf <- grf

plot(grf)
