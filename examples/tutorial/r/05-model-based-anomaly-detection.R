library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple

model <- hanr_arima()
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)
head(detection)

evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix

har_plot(model, dataset$serie, detection, dataset$event)

har_plot(
  model,
  attr(detection, "res"),
  detection,
  dataset$event,
  yline = attr(detection, "threshold")
)
