

# Install and load Harbinger and Nexus ------------------------------------
# install.packages("devtools")
#devtools::install_github("cefet-rj-dal/harbinger")

library(harbinger)
source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/develop/nexus.R")


# Load dataset ------------------------------------------------------------
devtools::install_github("cefet-rj-dal/event_datasets", force = TRUE)
library(dalevents)
data(gecco)

#Select a series and the desired time interval
#ph variable
#Interval of a day with anomalies
data <- subset(gecco$gecco[16500:18000,], select = c(ph, event))
names(data) <- c("series", "event")

data <- data[1:200,] #Use it only for fast test

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
  #Online detection
  online_detector <- detect(online_detector)
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
