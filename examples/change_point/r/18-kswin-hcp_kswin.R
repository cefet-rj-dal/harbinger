library(daltoolbox)
library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple

har_plot(harbinger(), dataset$serie)

model <- hcp_kswin(window_size = 100, stat_size = 30, alpha = 0.005)
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)
print(detection[detection$event, ])

evaluation <- evaluate(har_eval(), detection$event, dataset$event)
print(evaluation$confMatrix)

har_plot(model, dataset$serie, detection, dataset$event)
