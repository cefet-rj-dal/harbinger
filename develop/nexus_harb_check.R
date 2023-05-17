
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
#############################################################################
## Integration between Nexus + Harbinger + DALEvents
#############################################################################
# install.packages("devtools")
library(devtools)

# Install and load Harbinger, Nexus and DalEvents -----------------------------
devtools::install_github("cefet-rj-dal/harbinger",
                         force = TRUE, dep=FALSE, upgrade="never")

devtools::install_github("cefet-rj-dal/event_datasets",
                         force = TRUE, dep=FALSE, upgrade="never")

# Load packages
library(harbinger)
source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/develop/nexus.R")
#library(nexus)
library(dalevents)

# Load dataset ------------------------------------------------------------
#Selectdesired series and time interval
#ph variable
#Interval of a day with anomalies
data(gecco)
data <- subset(gecco$gecco[16500:18000,], select = c(ph, event))
data <- data[1:250,] #Use it only for fast test

#Finance - Oil brent prices
data(fi_br)
data <- subset(fi_br$Commodity, select = c(`Oil Brent`, Event))

#Adjust variabels names
names(data) <- c("series", "event")

# Run Nexus ---------------------------------------------------------------
#Prepare data to experiment
datasource <- nex_simulated_datasource("data", data$series)

#Create and setup objects
bt_size <- 30
online_detector <- nexus(datasource, fbiad(), batch_size = bt_size)
ef <- 0
bt_num <- 1
sld_bt <- 1


#Warmup nexus
online_detector <- warmup(online_detector)


#Sliding batches through series
while (!is.null(online_detector$datasource)) {
  #Create merge results
  if (sld_bt > 1) {
    x <- online_detector$detection
  }

  #Online detection
  online_detector <- detect(online_detector)

  #Create merge results
  if (sld_bt > 1) {
    online_detector_merged <- merge(x, online_detector$detection,
                                    by = "idx",
                                    all = TRUE)
  }

  print(paste("Current position:", online_detector$detection$idx[sld_bt]))
  print("Results:")
  print(table(online_detector$detection$event))
  print("--------------------------")

  #Batch information
  sld_bt <- sld_bt + 1
  if (sld_bt %% bt_size == 0) {
    bt_num <- bt_num + 1
  }
  print(paste("Batch:", bt_num))
  print("==========================")

  #Batch assign
  logic_res <- online_detector$detection$event == 1
  online_detector$detection$last_batch[logic_res] <- bt_num
  online_detector$detection$ef[logic_res] <- online_detector$detection$ef[logic_res] + 1
}

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
grf <- plot.harbinger(online_detector$detector, data$series,
                      online_detector$detection, data$event)
plot(grf)

View(online_detector$detection)
View(online_detector_merged)



# Another examples --------------------------------------------------------

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
