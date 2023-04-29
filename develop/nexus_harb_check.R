
# Loading Harbinger -------------------------------------------------------


# install.packages("devtools")
#devtools::install_github("cefet-rj-dal/harbinger")

library(harbinger)

#loading the example database
data(har_examples)

# Harbinger without Nexus -------------------------------------------------




#Using the time series 1
dataset <- har_examples[[1]]
head(dataset)


#ploting serie #1
plot(x = 1:length(dataset$serie), y = dataset$serie)
lines(x = 1:length(dataset$serie), y = dataset$serie)

# establishing fbiad method
model <- fbiad()



# fitting the model
model <- fit(model, dataset$serie)


# making detections using fbiad
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))


# evaluating the detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)


# ploting the results
grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
plot(grf)



# Nexus -------------------------------------------------------------------

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/develop/nexus.R")
source("~/harbinger/develop/nexus.R")

## primeiro caso # memória completa ----

datasource <- nex_simulated_datasource("data", har_examples[[1]]$serie)

online_detector_full <- nexus(datasource, har_arima(),
                              batch_size = 15)

online_detector_full <- warmup(online_detector_full)

while (!is.null(online_detector_full$datasource)) {
  online_detector_full <- detect(online_detector_full)
  print(table(online_detector_full$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector_full$stable_serie, online_detector_full$serie)))


## segundo caso - memória por batch ----

online_detector <- nexus(datasource, har_arima())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector$stable_serie, online_detector$serie)))


## terceiro caso - memória por batch fbiad ----

online_detector <- nexus(datasource, fbiad())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector$stable_serie, online_detector$serie)))



## quarto caso - memória por batch fbiad - gecco ph ----

source("https://raw.githubusercontent.com/cefet-rj-dal/event_datasets/main/gecco/carrega.R")

data <- carrega()
data <- subset(data$gecco, select = c(ph, event))

data <- data[16500:18000,]

datasource <- nex_simulated_datasource("data", data$ph)



online_detector <- nexus(datasource, fbiad())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(data-c(online_detector$stable_serie, online_detector$serie)))

#Sum of events
sum(online_detector$detection$event)

#Head of detections
head(online_detector$detection, 10)



# evaluating the detections
evaluation <- evaluate(online_detector$detector,
                       online_detector$detection$event,
                       data$event)

print(evaluation$confMatrix)



# ploting the results
grf <- plot.harbinger(online_detector$detector, data$ph,
                      online_detector$detection, data$event)
plot(grf)


## Try dalevents package ----
#install.packages("devtools")
devtools::install_github("cefet-rj-dal/event_datasets")
library(dalevents)

data(yahoo_a1)
?yahoo_a1

series <- yahoo_a1$real_13
summary(series)

plot(series$series, type = "l")


datasource <- nex_simulated_datasource("data", series$series)


online_detector <- nexus(datasource, fbiad(),
                         warm_size = 100, batch_size = 50, mem_batches = 3)

online_detector <- warmup(online_detector)

bt <- 1

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
  bt <- bt + 1
  print(paste('Batch:', bt))
}

#Sum of events
sum(online_detector$detection$event)

#Head of detections
head(online_detector$detection, 10)



# evaluating the detections
evaluation <- evaluate(online_detector$detector,
                       online_detector$detection$event,
                       series$event)

print(evaluation$confMatrix)



# ploting the results
grf <- plot.harbinger(online_detector$detector, series$series,
                      online_detector$detection, series$event)
plot(grf)
