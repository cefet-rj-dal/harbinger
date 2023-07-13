motifs_seqs <- function(detection) {
  iMotif <- NULL
  n <- nrow(detection)
  hasMotif <- !is.null(detection$seq)
  if (hasMotif) {
    iMotif <- rep(FALSE, n)
    posMotif <- !is.na(detection$seq)
    dMotif <- data.frame(start = (1:n)[posMotif], length = detection$seqlen[posMotif])
    repeat {
      if (nrow(dMotif) == 0)
        break
      iMotif[dMotif$start] <- TRUE
      dMotif$start <- dMotif$start + 1
      dMotif$length <- dMotif$length - 1
      dMotif <- dMotif[dMotif$length > 0,]
    }
  }
  return(iMotif)
}


#'@title Plot event detection on a time series
#'@description It accepts as input an object, a time series, a data.frame of events, a parameter to mark the detected change points, a threshold for the y-axis and an index for the time series
#'@param obj detector
#'@param serie time series
#'@param detection detections
#'@param event events
#'@param mark.cp mark change point
#'@param ylim limits for y-axis
#'@param idx labels for x observations
#'@return A line graph with dots, where the time series is plotted on the y-axis and the time index is plotted on the x-axis
#'@examples detector <- harbinger()
#'@import ggplot2
#'@export
har_plot <- function(obj, serie, detection, event=NULL, mark.cp=TRUE, ylim=NULL, idx = NULL){
  time <- 0
  if (is.null(idx))
    idx <- 1:length(serie)
  detection$event[is.na(detection$event)] <- FALSE

  data <- data.frame(time = idx, serie = serie, FP = detection$event, TP = FALSE, FN = FALSE, color="darkgray")
  data$CP <- detection$type == "changepoint"

  if (!is.null(event)) {
    data$TP <- detection$event & (event == detection$event)
    data$FP <- detection$event & (event != detection$event)
    data$FN <- event & (event != detection$event)
  }

  motifs_seqs <- motifs_seqs(detection)
  if (!is.null(motifs_seqs))
    data$color[motifs_seqs] <- "purple"

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
  if (mark.cp && (sum(data$CP, na.rm=TRUE) > 0)) {
    plot <- plot + geom_segment(aes(x=time, y=top_1, xend=time, yend=bottom_1),data = data[data$CP,], col="grey", size = 1, linetype="dashed")
  }

  plot <- plot + geom_hline(yintercept = top_1, col="black", size = 0.5)
  plot <- plot + geom_hline(yintercept = top_2, col="black", size = 0.5)

  plot <- plot + geom_hline(yintercept = bottom_1, col="black", size = 0.5)
  plot <- plot + geom_hline(yintercept = bottom_2, col="black", size = 0.5)
  return(plot)
}

