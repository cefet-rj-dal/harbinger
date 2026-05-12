library(daltoolbox)
library(harbinger)

source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))
data(examples_changepoints)
dataset <- examples_changepoints$complex

har_plot(harbinger(), dataset$serie)

model <- hcp_joinpoint(
  min_between = 20,
  min_end = 20,
  k_max = 1,
  log_transform = FALSE
)

set_example_seed()
model <- fit(model, dataset$serie)
model$model$comparison

detection <- detect(model, dataset$serie)
print(detection[detection$event, ])

evaluation <- evaluate(har_eval(), detection$event, dataset$event)
print(evaluation$confMatrix)

har_plot(model, dataset$serie, detection, dataset$event)
