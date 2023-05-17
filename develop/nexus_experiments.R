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

#Adjust variabels names
names(data) <- c("series", "event")


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
    grf <- plot.harbinger(online_detector$detector, data$serie[online_detector$detection$idx], online_detector$detection, data$event[online_detector$detection$idx])
    plot(grf)
    dev.off()

    bt <- bt + 1

    if(any(which(as.logical(online_detector$detection$event))>event_idx) & event_happened) {
      break
    }#comment this line for full result
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


model <- fbiad()

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
grf <- plot.harbinger(result$detector, data$series,
                      result$detection, data$event)
plot(grf)

View(result$detection)
