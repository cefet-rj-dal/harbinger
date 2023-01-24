#==== evdet_eventdetect: Function for event detection ====
#   eventdetect is an event detection method that consists of evaluating a dataframe and marking anomalies in the process, using
#   implemented algorithms from the EventDetectR package. This package can simulate, detect and classify the data from a time series.
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
# Not necessary for input:
#   windowSize: defines the size of the window. Default value = 200
#   nIterationsRefit: number of interactions. Default value = 150
#   dataPrepators:  prepares data. Default value = "ImputeTSInterpolation"
#   buildModelAlgo: model builder. Default value = "ForecastBats"
#   postProcessors: post processors. Default value = "bedAlgo"
#   postProcessorControl: Controller of post. Default value = list(nStandardDeviationsEventThreshhold = 5)
#

evtdet.eventdetect <- function(data,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  eventdetect <- function(data,windowSize=200,nIterationsRefit=150,
                          dataPrepators="ImputeTSInterpolation",buildModelAlgo="ForecastBats",
                          postProcessors="bedAlgo",postProcessorControl = list(nStandardDeviationsEventThreshhold = 5),...){

    require(EventDetectR)

    #browser()
    names(data) <- c("time",names(data)[-1])
    series_names <- ifelse(length(names(data)[-1])>1,"all",names(data)[-1])

    anomalies <-
      detectEvents(subset(data, select=-c(time)),windowSize=windowSize,nIterationsRefit=nIterationsRefit,
                   dataPrepators=dataPrepators,buildModelAlgo=buildModelAlgo,
                   postProcessors=postProcessors,postProcessorControl=postProcessorControl,...)$classification

    anomalies <- cbind.data.frame(time=data[anomalies$Event==TRUE,"time"],serie=series_names,type="anomaly")
    #anomalies$time <- as.POSIXct(as.numeric(anomalies$time),origin="1960-01-01")
    names(anomalies) <- c("time","serie","type")

    return(anomalies)
  }

  events <- evtdet(data,eventdetect,...)

  return(events)
}
