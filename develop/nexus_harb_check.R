
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

# establishing hanr_fbiad method
model <- hanr_fbiad()



# fitting the model
model <- fit(model, dataset$serie)


# making detections using hanr_fbiad
detection <- detect(model, dataset$serie)

# filtering detected events
print(detection |> dplyr::filter(event==TRUE))


# evaluating the detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)


# ploting the results
grf <- har_plot(model, dataset$serie, detection, dataset$event)
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
data <- data[1:100,] #Use it only for fast test

#Finance - Oil brent prices
data(fi_br)
data <- subset(fi_br$Commodity, select = c(`Oil Brent`, Event))

#Adjust variables names
names(data) <- c("series", "event")

# Run Nexus ---------------------------------------------------------------
run_nexus <- function(model, data, warm_size = 30, batch_size = 30, mem_batches = 0, png_folder="dev/plots/") {
  #Empty list to store results across batches
  res <- list()

  #Create auxiliary batch and slide counters
  bt_num <- 1
  sld_bt <- 1

  #Prepare data to experiment
  datasource <- nex_simulated_datasource("data", data$series)
  online_detector <- nexus(datasource, model, warm_size = warm_size, batch_size = batch_size, mem_batches = mem_batches)
  online_detector <- warmup(online_detector)


  #Sliding batches through series
  while (!is.null(online_detector$datasource)) {
    #Online detection
    online_detector <- detect(online_detector)

    #Parcial results
    print(paste("Current position:", online_detector$detection$idx[sld_bt]))
    print("Results:")
    print(table(online_detector$detection$event))
    print("--------------------------")

    #Store result metrics parameters across batches
    res_sld <- tibble::tibble(batch = bt_num,
                      slide = sld_bt,
                      ev_idx = which(online_detector$detection$event == 1))

    res[[sld_bt]] <- res_sld

    #Update batch and slide counters
    sld_bt <- sld_bt + 1
    if (sld_bt %% batch_size == 0) {
      bt_num <- bt_num + 1
    }

    print(paste("Batch:", bt_num))
    print("==========================")

  }

  online_detector$res <- res
  return(online_detector)
}


#Create and setup objects
bt_size <- 10
wm_size <- 30
model <- hanr_fbiad()

result <- run_nexus(model=model, data=data, warm_size=wm_size, batch_size=bt_size, mem_batches=0, png_folder="dev/plots/")

#Sum of events
sum(result$detection$event)

#Head of detections
ev_idx <- which(result$detection$event == 1)

head(result$detection[ev_idx,])

# evaluating the detections
evaluation <- evaluate(result$detector,
                       result$detection$event,
                       data$event)

print(evaluation$confMatrix)




# ploting the results
grf <- har_plot(result$detector, data$series,
                      result$detection, data$event)
plot(grf)

View(result$detection)
View(result$res)

View(result$res[[100]])
View(result$res[[150]])
View(result$res[[300]])
View(result$res[[600]])
View(result$res[[length(result$res)]])



### DRAFT - RECOVER IF NECESSARY
#Batch assign
#ef + bf
#online_detector$detection$ef[ev_idx] <- online_detector$detection$ef[ev_idx] + 1

#first bach + last batch
#logic_fb <- which((online_detector$detection$event == 1) & (online_detector$detection$first_batch == 0))

#online_detector$detection$first_batch[logic_fb]  <- bt_num
#online_detector$detection$last_batch[ev_idx] <- bt_num
#online_detector$detection[ev_idx,]$bf <- bt_num - as.integer((result$detection[ev_idx,]$idx - wm_size) / bt_size)

# Another examples --------------------------------------------------------

source("~/harbinger/develop/nexus.R")

## primeiro caso # memória completa ----

datasource <- nex_simulated_datasource("data", har_examples[[1]]$serie)

online_detector_full <- nexus(datasource, hanr_arima(),
                              batch_size = 15)

online_detector_full <- warmup(online_detector_full)

while (!is.null(online_detector_full$datasource)) {
  online_detector_full <- detect(online_detector_full)
  print(table(online_detector_full$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector_full$stable_serie, online_detector_full$serie)))


## segundo caso - memória por batch ----

online_detector <- nexus(datasource, hanr_arima())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector$stable_serie, online_detector$serie)))


## terceiro caso - memória por batch hanr_fbiad ----

online_detector <- nexus(datasource, hanr_fbiad())

online_detector <- warmup(online_detector)

while (!is.null(online_detector$datasource)) {
  online_detector <- detect(online_detector)
  print(table(online_detector$detection$event))
}

print(sum(har_examples[[1]]$serie-c(online_detector$stable_serie, online_detector$serie)))



## quarto caso - memória por batch hanr_fbiad - gecco ph ----

source("https://raw.githubusercontent.com/cefet-rj-dal/event_datasets/main/gecco/carrega.R")

data <- carrega()
data <- subset(data$gecco, select = c(ph, event))

data <- data[16500:18000,]

#Adjust variables names
names(data) <- c("series", "event")

datasource <- nex_simulated_datasource("data", data$series)


online_detector <- nexus(datasource, har_hanr_fbiad())

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
grf <- har_plot(online_detector$detector, data$ph,
                      online_detector$detection, data$event)
plot(grf)



###Rebecca Version###

# Run Nexus ---------------------------------------------------------------
run_nexus <- function(model, data, warm_size = 30, batch_size = 15, mem_batches = 0, png_folder="dev/plots/"){

  datasource <- nex_simulated_datasource("data", data$serie)
  online_detector <- nexus(datasource, model, warm_size = warm_size, batch_size = batch_size, mem_batches = mem_batches)
  online_detector <- warmup(online_detector)

  bt <- 1
  event_happened <- FALSE
  bt_event_happened <- 0
  event_idx <- 0

  while (!is.null(online_detector$datasource)) {

    online_detector <- detect(online_detector)
    #print(table(online_detector$detection$event))

    #for plotting
    if(any(data$event[online_detector$detection$idx]) & !event_happened){
      event_happened <- TRUE
      event_idx <- which(data$event[online_detector$detection$idx])
      bt_event_happened <- bt
    }

    png(file=paste0(png_folder,"batch_",bt,".png"),
        width=600, height=350)
    grf <- har_plot(online_detector$detector, data$serie[online_detector$detection$idx], online_detector$detection, data$event[online_detector$detection$idx])
    plot(grf)
    dev.off()

    bt <- bt + 1

    #if(any(which(as.logical(online_detector$detection$event))>event_idx) & event_happened) {
    break
    #}#comment this line for full result
    #end
  }

  return(list(detector=online_detector$detector,detection=online_detector$detection))
}

#Example of usage

# establishing method
model <- har_herald(lag_pred=lag_pred, online_step=online_step,
                    decomp_fun, decomp_par,
                    pred_fun, pred_par,
                    detect_fun, detect_par)


model <- hanr_fbiad()

#FULL MEMORY
result <- run_nexus(model, data, warm_size = 30, batch_size = 15, mem_batches = 0, png_folder="develop/plots/")



#Sum of events
sum(result$detection$event)

#Head of detections
head(result$detection, 10)

# evaluating the detections
evaluation <- evaluate(result$detector,
                       result$detection$event,
                       data$event)

print(evaluation$confMatrix)



# ploting the results
grf <- har_plot(result$detector, data$series,
                      result$detection, data$event)
plot(grf)

View(result$detection)
