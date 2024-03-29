library(daltoolbox)

#loading the example database
data(har_examples)

#Using example 1
dataset <- har_examples$example1
head(dataset)

# setting up time series emd detector
model <- hanr_remd()

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])



