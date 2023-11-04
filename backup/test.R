library(daltoolbox)

#loading the example database
data(har_examples)

#Using example 1
dataset <- har_examples$example1
head(dataset)

# setting up time series regression model
model <- hanr_arima()

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))
