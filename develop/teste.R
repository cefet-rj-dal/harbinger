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

dataset$event <- as.character(dataset$event)
dataset$event[dataset$event == "FALSE"] <- "c0"
dataset$event[dataset$event == "TRUE"] <- "c1"
dataset$event <- factor(dataset$event, labels=c("c0", "c1"))

slevels <- levels(dataset$event)

train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
describe(norm)
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)

if (FALSE) {
  model <- cla_mlp("event", slevels, size=3,decay=0.03)
  model <- cla_nb("event", slevels)
  model <- cla_knn("event", slevels, k=3)
  model <- cla_rf("event", slevels, mtry=3, ntree=5)
  model <- cla_svm("event", slevels, epsilon=0.0,cost=20.000)
  model <- cla_dtree("event", slevels)
  model <- cla_majority("event", slevels)

  print(describe(model))
  model <- fit(model, train_n)
  train_prediction <- predict(model, train_n)
}

if (TRUE) {
  model <- har_cla(cla_majority("event", slevels))
  # fitting the model
  model <- fit(model, train_n)

  # making detections using cla mlp
  detection <- detect(model, train_n)

  # filtering detected events
  print(detection |> dplyr::filter(event==TRUE))

  # evaluating the detections
  evaluation <- evaluate(model, detection$event, train_n$event == "c1")
  print(evaluation$confMatrix)

  # ploting the results
  grf <- plot.harbinger(model, train_n$serie, detection, train_n$event == "c1")
  plot(grf)


  test_n <- transform(norm, test)

  # making detections using cla mlp
  detection <- detect(model, test_n)

  # filtering detected events
  print(detection |> dplyr::filter(event==TRUE))

  # evaluating the detections
  evaluation <- evaluate(model, detection$event, test_n$event == "c1")
  print(evaluation$confMatrix)

  # ploting the results
  grf <- plot.harbinger(model, test_n$serie, detection, test_n$event == "c1")
  plot(grf)

}

