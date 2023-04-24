# Harbinger Package
# version 1.0.20

#source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/jupyter_harbinger.R")

#loading Harbinger
#load_harbinger()

#loading the example database
data(har_examples)

#Using the time series 1
dataset <- har_examples[[17]]
head(dataset)

#ploting serie #1

plot(x = 1:length(dataset$serie), y = dataset$serie)
lines(x = 1:length(dataset$serie), y = dataset$serie)

# establishing mlp method
library(ROCR)
library(RSNNS)
library(nnet)
library(MLmetrics)
library(nnet)


slevels <- levels(factor(dataset$event, labels=c("FALSE", "TRUE")))

train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
describe(norm)
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)



#model <- cla_mlp("event", slevels, size=3,decay=0.03)
#print(describe(model))
#model <- fit(model, dataset)
#train_prediction <- predict(model, dataset)

model <- har_cla(cla_mlp("event", slevels, size=3,decay=0.03))
# fitting the model
model <- fit(model, train_n)

# making detections using cla mlp
detection <- detect(model, train_n)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))

# evaluating the detections
evaluation <- evaluate(model, detection$event, train_n$event)
print(evaluation$confMatrix)

# ploting the results
grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
plot(grf)
