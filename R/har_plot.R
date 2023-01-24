#==== plot: Function for plotting event detection ====
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   events: output from 'evtdet' function regarding a particular times series.
#   reference: data.frame of the same length as the time series with two variables: time, event (boolean indicating true events)
# output:
#   plot.
#'@export
plot.harbinger <- function(obj, serie, detections, events=NULL, reference=NULL, mark.cp=FALSE, ylim=NULL, ...){
  serie_name <- names(data)[-1]
  names(data) <- c("time","serie")

  #Time of detected events
  events_true <- events
  #Time of detected events of type change points
  events_cp <- as.data.frame(events[events$type=="change point",])
  #Time of detected events of type anomaly
  events_a <- as.data.frame(events[events$type=="anomaly",])
  #Time of detected events of type volatility anomaly
  events_va <- as.data.frame(events[events$type=="volatility anomaly",])

  #Data observation of detected events
  data_events_true <- as.data.frame(data[data$time %in% events$time,])

  #If true events are identified
  if(!is.null(reference)) {
    names(reference) <- c("time","event")

    #Time of identified true events
    ref_true <- as.data.frame(reference[reference$event==TRUE,])
    #Time of identified true events that were correctly detected
    ref_events_true <- as.data.frame(ref_true[ref_true$time %in% events$time,])

    #Data observation of identified true events
    data_ref_true <- as.data.frame(data[data$time %in% ref_true$time,])
    #Data observation of identified true events that were correctly detected
    data_ref_events_true <- as.data.frame(data[data$time %in% ref_events_true$time,])
  }

  min_data <- min(data$serie)
  max_data <- max(data$serie)
  if(!is.null(ylim)){
    min_data <- ifelse(!is.na(ylim[1]), ylim[1], min(data$serie))
    max_data <- ifelse(!is.na(ylim[2]), ylim[2], max(data$serie))
  }

  top_1 <- max_data+(max_data-min_data)*0.02
  top_2 <- max_data+(max_data-min_data)*0.05
  bottom_1 <- min_data-(max_data-min_data)*0.02
  bottom_2 <- min_data-(max_data-min_data)*0.05


  require(ggplot2)
  #Plotting time series
  plot <- ggplot(data, aes(x=time, y=serie)) +
    geom_line()+
    xlab("Time")+
    ylab("")+#ylab(serie_name)+
    theme_bw()

  #Setting y limits if provided
  if(!is.null(ylim)) plot <- plot + ggplot2::ylim(bottom_2,top_2)
  #browser()
  #Plotting top bar
  tryCatch(if(nrow(ref_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data=ref_true, col="blue"),
    error = function(e) NULL)
  tryCatch(if(nrow(events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data=events_true, col="red"),
    error = function(e) NULL)
  tryCatch(if(nrow(ref_events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data=ref_events_true, col="green"),
    error = function(e) NULL)
  plot <- plot + geom_hline(yintercept = top_1, col="black", size = 0.5)
  plot <- plot + geom_hline(yintercept = top_2, col="black", size = 0.5)

  #Plotting bottom bar
  tryCatch(if(nrow(ref_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data=ref_true, col="blue"),
    error = function(e) NULL)
  tryCatch(if(nrow(events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data=events_true, col="red"),
    error = function(e) NULL)
  tryCatch(if(nrow(ref_events_true)>0)
    plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data=ref_events_true, col="green"),
    error = function(e) NULL)
  plot <- plot + geom_hline(yintercept = bottom_1, col="black", size = 0.5)
  plot <- plot + geom_hline(yintercept = bottom_2, col="black", size = 0.5)

  #Plotting relevant event points of type anomaly
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_true,time %in% events_a$time), col="blue", size = 1),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_events_true,time %in% events_a$time), col="red", size = 1),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_events_true,time %in% events_a$time), col="green", size = 1),
           error = function(e) NULL)

  #Plotting relevant event points of type volatility anomaly
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_true,time %in% events_va$time), shape = 17, col="blue", size = 2),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_events_true,time %in% events_va$time), shape = 17, col="red", size = 2),
           error = function(e) NULL)
  tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=subset(data_ref_events_true,time %in% events_va$time), shape = 17, col="green", size = 2),
           error = function(e) NULL)

  #Plotting relevant event points
  if(nrow(events_a)==0 & nrow(events_va)==0) {
    tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=data_ref_true, col="blue", size = 1),
             error = function(e) NULL)
    tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=data_events_true, col="red", size = 1),
             error = function(e) NULL)
    tryCatch(plot <- plot + geom_point(aes(x=time, y=serie),data=data_ref_events_true, col="green", size = 1),
             error = function(e) NULL)
  }

  #Plotting change points
  if(mark.cp & nrow(events_cp)>0)
    tryCatch(plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=bottom_1),data=events_cp, col="grey", size = 1, linetype="dashed"),
             error = function(e) NULL)


  return(plot)
}
