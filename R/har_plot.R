motifs_seqs <- function(detection) {
  iMotif <- NULL
  if (!is.null(detection)) {
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
  }
  return(iMotif)
}


#'@title Plot event detection on a time series
#'@description It accepts as harbinger, a time series, a data.frame of events, a parameter to mark the detected change points, a threshold for the y-axis and an index for the time series
#'@param obj harbinger detector
#'@param serie time series
#'@param detection detection
#'@param event events
#'@param mark.cp show change points
#'@param ylim limits for y-axis
#'@param idx labels for x observations
#'@param pointsize default point size
#'@param colors default colors for event detection: green is TP, blue is FN, red is FP, purple means observations that are part of a sequence.
#'@param yline values for plotting horizontal dashed lines
#'@return A time series plot with marked events
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_anomalies)
#'
#'#Using the simple time series
#'dataset <- examples_anomalies$simple
#'head(dataset)
#'
#'# setting up time change point using GARCH
#'model <- hanr_arima()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
#'# making detections
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'# evaluating the detections
#'evaluation <- evaluate(har_eval_soft(), detection$event, dataset$event)
#'print(evaluation$confMatrix)
#'
#'# ploting the results
#'grf <- har_plot(model, dataset$serie, detection, dataset$event)
#'plot(grf)
#'@import ggplot2
#'@export
har_plot <- function (obj, serie, detection = NULL, event = NULL, mark.cp = TRUE, ylim = NULL, idx = NULL, pointsize=0.5, colors=c("green", "blue", "red", "purple"), yline = NULL)
{
  time <- 0
  if (is.null(idx))
    idx <- 1:length(serie)
  if (!is.null(detection)) {
    detection_event <- detection$event
    detection_event[is.na(detection_event)] <- FALSE
    CP <- detection$type == "changepoint"
  }
  else {
    detection_event <- FALSE
    CP <- FALSE
  }

  data <- data.frame(time = idx, serie = serie, FP = detection_event,
                     TP = FALSE, FN = FALSE, CP = CP, color = "black", size=pointsize)
  if (!is.null(event)) {
    data$TP <- detection_event & (event == detection_event)
    data$FP <- detection_event & (event != detection_event)
    data$FN <- event & (event != detection_event)
  }
  motifs_seqs <- motifs_seqs(detection)
  if (!is.null(motifs_seqs)) {
    data$size[motifs_seqs] <- 0.75
    data$color[motifs_seqs] <- colors[4] #purple
  }
  data$color[data$TP] <- colors[1] #green
  data$color[data$FN] <- colors[2] #blue
  data$color[data$FP] <- colors[3] #red
  data$size[data$FN | data$TP | data$FP] <- 1.5

  min_data <- min(serie)
  max_data <- max(serie)
  if (!is.null(ylim)) {
    min_data <- ifelse(!is.na(ylim[1]), ylim[1], min(serie))
    max_data <- ifelse(!is.na(ylim[2]), ylim[2], max(serie))
  }
  top_1 <- max_data + (max_data - min_data) * 0.02
  top_2 <- max_data + (max_data - min_data) * 0.05
  bottom_1 <- min_data - (max_data - min_data) * 0.02
  bottom_2 <- min_data - (max_data - min_data) * 0.05
  plot <- ggplot(data, aes(x = time, y = serie)) + geom_point(colour = data$color, size=data$size) +
    geom_line() + xlab("") + ylab("") + theme_bw()
  plot <- plot + theme(panel.grid.major = element_blank()) + theme(panel.grid.minor = element_blank())

  if (!is.null(ylim))
    plot <- plot + ggplot2::ylim(bottom_2, top_2)
  if (mark.cp && (sum(data$CP, na.rm = TRUE) > 0)) {
    plot <- plot + geom_segment(aes(x = time, y = top_1, xend = time, yend = bottom_1),
                                data = data[data$CP, ], col = "grey", size = 1, linetype = "dashed")
  }

  if (!is.null(yline))
    plot <- plot + geom_hline(yintercept = yline, col = "lightgrey", size = 1, linetype = "dotted")

  return(plot)
}
