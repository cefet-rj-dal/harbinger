# Harbinger Package
# version 1.0.9


#loading the example database
data(har_examples)

#Using the time series 1
dataset <- har_examples[[14]]
#dataset <- har_examples[[9]]
head(dataset)

#ploting serie #1

#plot(x = 1:length(dataset$serie), y = dataset$serie)
#lines(x = 1:length(dataset$serie), y = dataset$serie)

# establishing change finder arima method
model <- change_point_garch()
#model <- change_finder_arima()
#model <- change_finder_ets()
#model <- har_garch()

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



