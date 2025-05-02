library(daltoolbox)

#loading the example database
data(examples_anomalies)

#Using the simple
dataset <- examples_anomalies$simple
head(dataset)

# setting up time change point using GARCH
model <- hcp_garch()

# fitting the model
model <- fit(model, dataset$serie)

# making detections
detection <- detect(model, dataset$serie)
detection$event[55] <- TRUE
dataset$event[56] <- TRUE

# filtering detected events
print(detection[(detection$event),])

# evaluating the detections
evaluation <- evaluate.har_eval_soft(har_eval_soft(), detection$event, dataset$event)
print(evaluation$confMatrix)

# ploting the results
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
