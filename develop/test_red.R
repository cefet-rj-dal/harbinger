library(daltoolbox)
library(zoo)

set.seed(1)

#loading the example database
data(har_examples)

#Using example 6
dataset <- har_examples$example6
head(dataset)

# setting up change point method
model <- hcp_red()

# fitting the model
model <- fit(model, dataset$serie)

# execute the detection method
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])
