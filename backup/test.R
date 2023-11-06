library(daltoolbox)

#loading the example database
data(har_examples)

#Using example 15
dataset <- har_examples$example15
head(dataset)

# setting up time series regression model
model <- hmo_sax(26, 3, 3)

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))

# setting up time series regression model
model <- hmo_base36(37, 3, 3)

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])
