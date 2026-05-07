library(daltoolbox)
library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple

model <- hcp_bocpd(hazard = 100, dist = "gaussian", threshold = 0.5)
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)

print(detection[detection$event, ])
har_plot(model, dataset$serie, detection, dataset$event)
