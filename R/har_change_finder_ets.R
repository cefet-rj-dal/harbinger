#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
#'@import forecast
#'@import rugarch
#'@import TSPred
change_finder_ets <- function(alpha = 1.5, w = 5) {
  obj <- harbinger()
  obj$alpha <- alpha
  obj$w <- w
  class(obj) <- append("change_finder_ets", class(obj))
  return(obj)
}

#'@export
detect.change_finder_ets <- function(obj, serie) {
  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- na.omit(serie)

  #Adjusting a model to the entire series
  M1 <- forecast::ets(ts(serie))

  #Adjustment error on the entire series
  s <- residuals(M1)^2
  outliers <- outliers.boxplot.index(s, obj$alpha)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers[1:obj$w] <- FALSE

  y <- TSPred::mas(s, obj$w)

  #Adjusting to the entire series
  M2 <- forecast::ets(ts(y))

  #Adjustment error on the whole window
  u <- residuals(M2)^2

  u <- TSPred::mas(u, obj$w)
  cp <- outliers.boxplot.index(u)
  group_cp <- split(cp, cumsum(c(1, diff(cp) != 1)))
  cp <- rep(FALSE, length(u))
  for (g in group_cp) {
    if (length(g) > 0) {
      i <- min(g)
      cp[i] <- TRUE
    }
  }
  cp[1:obj$w] <- FALSE
  cp <- c(rep(FALSE, length(s)-length(u)), cp)

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  i_cp <- rep(NA, n)
  i_cp[non_na] <- cp

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"
  detection$event[cp] <- TRUE
  detection$type[cp] <- "change_point"

  return(detection)
}

