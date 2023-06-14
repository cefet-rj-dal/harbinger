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
data <- data[1:250,] #Use it only for fast test

#Finance - Oil brent prices
data(fi_br)
data <- subset(fi_br$Commodity, select = c(`Oil Brent`, Event))

#Adjust variables names
names(data) <- c("series", "event")



# Nexus -------------------------------------------------------------------
# Run Nexus ---------------------------------------------------------------
run_nexus <- function(model, data, warm_size = 30, batch_size = 30, mem_batches = 0, png_folder="dev/plots/") {
  #require(tibble)

  #Empty list to store results across batches
  res <- list()
  hist <- list()
  #tempo <- list()

  #Create auxiliary batch and slide counters
  bt_num <- 1
  sld_bt <- 1

  #Prepare data to experiment
  datasource <- nex_simulated_datasource("data", data$series)
  online_detector <- nexus(datasource, model, warm_size = warm_size, batch_size = batch_size, mem_batches = mem_batches)
  online_detector <- warmup(online_detector)

  ##TEMPO START
  #Sliding batches through series
  while (!is.null(online_detector$datasource)) {
    #Online detection
    online_detector <- detect(online_detector)

    #Partial results
    print(paste("Current position:", online_detector$detection$idx[sld_bt]))
    print("Results:")
    print(table(online_detector$detection$event))
    print("--------------------------")


    #Update batch and slide counters and historical results
    sld_bt <- sld_bt + 1
    if (sld_bt %% batch_size == 0) {
      #Store result metrics parameters across batches - Idx of marked events
      res_sld <- tibble::tibble(batch = bt_num,
                                ev_idx = which(online_detector$detection$event == 1))

      res[[bt_num]] <- res_sld

      #Store result metrics parameters across batches - Complete historic events column
      hist_sld <- tibble::tibble(batch = bt_num,
                                 idx = online_detector$detection$idx,
                                 ev = online_detector$detection$event)

      hist[[bt_num]] <- hist_sld

      bt_num <- bt_num + 1
      ##TEMPO DO SISTEMA

    }

    print(paste("Batch:", bt_num))
    print("==========================")

  }

  #Adding last batch results
  res_sld <- tibble::tibble(batch = bt_num,
                            ev_idx = which(online_detector$detection$event == 1))

  res[[bt_num]] <- res_sld

  hist_sld <- tibble::tibble(batch = bt_num,
                             idx = online_detector$detection$idx,
                             ev = online_detector$detection$event)

  hist[[bt_num]] <- hist_sld


  online_detector$res <- res
  online_detector$hist <- hist
  return(online_detector)
}


#Create and setup objects
bt_size <- 30
wm_size <- 30


# establishing method
model <- har_herald(lag_pred=lag_pred, online_step=online_step,
                    decomp_fun, decomp_par,
                    pred_fun, pred_par,
                    detect_fun, detect_par)

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

#View results across batches (example using Gecco Challenge complete ph series)
View(result$res[[1]])
View(result$res[[length(result$res)/3]])
View(result$res[[length(result$res)/2]])
View(result$res[[length(result$res)]])

View(result$hist[[1]])
View(result$hist[[length(result$hist)/3]])
View(result$hist[[length(result$hist)/2]])
View(result$hist[[length(result$hist)]])
