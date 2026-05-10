library(daltoolbox)
library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple

har_plot(harbinger(), dataset$serie)

model <- hcp_page_hinkley(min_instances = 30, delta = 0.005, threshold = 3, alpha = 0.999)
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)
print(detection[detection$event, ])

evaluation <- evaluate(har_eval(), detection$event, dataset$event)
print(evaluation$confMatrix)

har_plot(model, dataset$serie, detection, dataset$event)
