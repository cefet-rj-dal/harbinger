# Harbinger Package
# version 1.0.9

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/jupyter_harbinger.R")

#loading Harbinger
load_harbinger()

#loading the example database
data(har_examples)

#Using the time series 1
dataset <- har_examples[[1]]
head(dataset)

#ploting serie #1

plot(x = 1:length(dataset$serie), y = dataset$serie)
lines(x = 1:length(dataset$serie), y = dataset$serie)

# establishing garch method
model <- har_kmeans(1)

# fitting the model
model <- fit(model, dataset$serie)

# making detections using fbiad
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))

# evaluating the detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

# ploting the results
grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
plot(grf)

