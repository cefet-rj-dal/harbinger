#############################################################################
## Integration between Nexus + Harbinger + DALEvents
#############################################################################
# install.packages("devtools")
library(devtools)

# Install and load Harbinger, Nexus and DalEvents -----------------------------
devtools::install_github("cefet-rj-dal/harbinger", force = TRUE, dep=FALSE, upgrade="never")
devtools::install_github("cefet-rj-dal/event_datasets", force = TRUE, dep=FALSE, upgrade="never")

# Load packages
library(harbinger)
source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/develop/nexus.R")
library(dalevents)


# Load dataset ------------------------------------------------------------
#Selectdesired series and time interval
#ph variable
#Interval of a day with anomalies
data(gecco)
data <- subset(gecco$gecco[16500:18000,], select = c(ph, event))
#data <- data[1:100,] #Use it only for fast test

#Finance - Oil brent prices
data(fi_br)
data <- subset(fi_br$Commodity, select = c(`Oil Brent`, Event))

#Adjust variabels names
names(data) <- c("series", "event")



# Nexus -------------------------------------------------------------------
# Run Nexus ---------------------------------------------------------------
run_nexus <- function(model, data, warm_size = 30, batch_size = 30, mem_batches = 0, png_folder="dev/plots/") {
  require(magrittr)
  require(tidyverse)

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
    res_sld <- tibble(batch = bt_num,
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
model <- fbiad()

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
grf <- plot.harbinger(result$detector, data$series,
                      result$detection, data$event)
plot(grf)

View(result$detection)
View(result$res)

View(result$res[[100]])
View(result$res[[150]])
View(result$res[[300]])
View(result$res[[600]])
View(result$res[[length(result$res)]])

