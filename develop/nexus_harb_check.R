# install.packages("devtools")
devtools::install_github("cefet-rj-dal/harbinger")

library(harbinger)

#loading the example database
data(har_examples)

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

#source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/develop/nexus.R")
source("~/nexus/nexus.R")


#primeiro caso # memória completa

datasource <- nex_simulated_datasource("data", har_examples[[1]]$serie)

online_detector_full <- nexus(datasource, har_arima(), 
                              batch_size = 15)

online_detector_full <- warmup(online_detector_full)

while (!is.null(online_detector_full$datasource)) {
  online_detector_full <- detect(online_detector_full)
  print(table(online_detector_full$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector_full$stable_serie, online_detector_full$serie)))


#segundo caso # memória por batch

online_detector <- nexus(datasource, har_arima())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector$stable_serie, online_detector$serie)))


#terceiro caso
# memória por batch fbiad

online_detector <- nexus(datasource, fbiad())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector$stable_serie, online_detector$serie)))



#quarto caso
# memória por batch fbiad - gecco ph

source("https://raw.githubusercontent.com/cefet-rj-dal/event_datasets/main/gecco/carrega.R")
#install.packages("strucchange")
library(strucchange)
#install.packages("TSA")
library(TSA)
#install.packages("urca")
library(urca)
#install.packages("mFilter")
library(mFilter)


data <- carrega()
data <- subset(data$gecco, select = c(ph))
data <- data$ph[16500:18000]

datasource <- nex_simulated_datasource("data", data)



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
head(online_detector$detection, 30)
