library(daltoolbox)

#loading the example database
data(examples_changepoints)

#Using simple example
dataset <- examples_changepoints$simple
head(dataset)

# setting up change point method
model <- hcp_red()

# fitting the model
model <- fit(model, dataset$serie)

# execute the detection method
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])
