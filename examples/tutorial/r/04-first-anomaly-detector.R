library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple

har_plot(harbinger(), dataset$serie, event = dataset$event)

model <- hanr_histogram(density_threshold = 0.05)
detection <- detect(model, dataset$serie)
head(detection)

evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix

har_plot(model, dataset$serie, detection, dataset$event)
