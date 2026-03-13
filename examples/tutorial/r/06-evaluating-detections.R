library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
model <- hanr_arima()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)

hard_eval <- har_eval()
hard_result <- evaluate(hard_eval, detection$event, dataset$event)
hard_result$confMatrix

soft_eval <- har_eval_soft()
soft_result <- evaluate(soft_eval, detection$event, dataset$event)
soft_result$confMatrix

hard_result
soft_result
