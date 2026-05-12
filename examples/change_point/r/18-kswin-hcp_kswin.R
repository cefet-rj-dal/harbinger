library(daltoolbox)
library(harbinger)

source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/main/examples/seed.R"))
data(examples_changepoints)
dataset <- examples_changepoints$complex

har_plot(harbinger(), dataset$serie)

model <- hcp_kswin(window_size = 100, stat_size = 30, alpha = 0.005)
set_example_seed()
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)
print(detection[detection$event, ])

evaluation <- evaluate(har_eval(), detection$event, dataset$event)
print(evaluation$confMatrix)

har_plot(model, dataset$serie, detection, dataset$event)
