set.seed(1)

library(daltoolbox)

#loading the example database
data(examples_anomalies)

#Using simple example
dataset <- examples_anomalies$simple
head(dataset)

# setting up time series emd detector
model <- hanr_fbiad()

utils <- harutils()

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])


res <-  attr(detection, "res")

data <- res

index <- which(data > mean(data) + 3*sd(data))

plot(res)

boxplot(res)
