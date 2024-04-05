library(daltoolbox)
library(zoo)

#loading the example database
data(har_examples)

#Using example 1
dataset <- har_examples$example1
head(dataset)

# setting up time series emd detector
model <- hanr_red(red_cp = FALSE, volatility_cp = FALSE, trend_cp = FALSE)

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])

grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
