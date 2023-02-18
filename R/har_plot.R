#==== plot: Function for plotting detection detection ====
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   detection: output from 'evtdet' function regarding a particular times series.
#   event: data.frame of the same length as the time series with two variables: time, detection (boolean indicating true detection)
# output:
#   plot.
#'@import ggplot2
#'@export
#use_package('ggplot2')
plot.harbinger <- function(obj, serie, detection, event=NULL, mark.cp=TRUE, ylim=NULL, idx = NULL){
  if (is.null(idx))
    idx <- 1:length(serie)
  detection$event[is.na(detection$event)] <- FALSE

  data <- data.frame(time = idx, serie = serie, FP = detection$event, TP = FALSE, FN = FALSE, color="darkgray")
  if (!is.null(event)) {
    data$TP <- detection$event & (event == detection$event)
    data$FP <- detection$event & (event != detection$event)
    data$FN <- event & (event != detection$event)
    data$CP <- detection$type == "change_point"
  }

  data$color[data$FN] <- "blue"
    data$color[data$TP] <- "green"
      data$color[data$FP] <- "red"

      min_data <- min(serie)
      max_data <- max(serie)
      if(!is.null(ylim)){
        min_data <- ifelse(!is.na(ylim[1]), ylim[1], min(serie))
        max_data <- ifelse(!is.na(ylim[2]), ylim[2], max(serie))
      }

      top_1 <- max_data+(max_data-min_data)*0.02
      top_2 <- max_data+(max_data-min_data)*0.05
      bottom_1 <- min_data-(max_data-min_data)*0.02
      bottom_2 <- min_data-(max_data-min_data)*0.05

      #Plotting time series
      plot <- ggplot(data, aes(x=time, y=serie)) + geom_point(colour=data$color) + geom_line() +
        xlab("") +
        ylab("") +
        theme_bw()

      if(!is.null(ylim))
        plot <- plot + ggplot2::ylim(bottom_2,top_2)

      if (sum(data$FN) > 0){
        plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data = data[data$FN,], col="blue")
        plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data = data[data$FN,], col="blue")
      }
      if (sum(data$TP) > 0) {
        plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data = data[data$TP,], col="green")
        plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data = data[data$TP,], col="green")
      }
      if (sum(data$FP) > 0) {
        plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=top_2),data = data[data$FP,], col="red")
        plot <- plot + geom_segment(aes(x=time, y=bottom_1, xend=time, yend=bottom_2),data = data[data$FP,], col="red")
      }
      if (mark.cp && (sum(data$CP) > 0)) {
        plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=bottom_1),data = data[data$CP,], col="grey", size = 1, linetype="dashed")
      }

      plot <- plot + geom_hline(yintercept = top_1, col="black", size = 0.5)
      plot <- plot + geom_hline(yintercept = top_2, col="black", size = 0.5)

      plot <- plot + geom_hline(yintercept = bottom_1, col="black", size = 0.5)
      plot <- plot + geom_hline(yintercept = bottom_2, col="black", size = 0.5)
      return(plot)
}
