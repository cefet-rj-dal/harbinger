library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple
head(dataset)

har_plot(harbinger(), dataset$serie, event = dataset$event)

model <- hcp_amoc()
detection <- detect(model, dataset$serie)
detection

har_plot(model, dataset$serie, detection, dataset$event)
