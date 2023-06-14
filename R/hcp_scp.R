#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export
hcp_scp <- function(sw = 30, alpha = 1.5) {
  obj <- harbinger()
  obj$sw <- sw
  obj$alpha <- alpha
  class(obj) <- append("hcp_scp", class(obj))
  return(obj)
}

analyze_window <- function(data, offset) {
  n <- length(data)
  y <- data.frame(t = 1:n, y = data)

  mdl <- lm(y~t, y)
  err <- mean(mdl$residuals^2)

  y_a <- y[1:(offset-1),]
  mdl_a <- lm(y~t, y_a)
  y_d <- y[(offset+1):n,]
  mdl_d <- lm(y~t, y_d)

  err_ad <- mean(c(mdl_a$residuals,mdl_d$residuals)^2)

  #return 1-error on whole window; 2-error on window halves; 3-error difference
  return(data.frame(mdl=err, mdl_ad=err_ad, mdl_dif=err-err_ad))
}


#'@title Detect change points in time series
#'
#'@description The function takes an object object and a serial time series as input
#'
#'@details Detection is done by applying the analyze_window function to each sliding window of data and identifying points with significantly different fit error between the two halves of the window. These points are marked as change points
#'
#'@param obj
#'@param serie
#'
#'@examples
#'
#'@return The function returns a dataframe indicating the occurrence of change points at each point in the series
#'
#'@export
detect.hcp_scp <- function(obj, serie) {

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  sx <- ts_data(na.omit(serie), obj$sw)
  obj$offset <- round(obj$sw/2)

  #===== Analyzing all data windows ======
  errors <- do.call(rbind,apply(sx, 1, analyze_window, obj$offset))

  #Returns index of windows with outlier error differences
  index.cp <- har_outliers(errors$mdl_dif, obj$alpha)
  index.cp <- c(rep(FALSE, obj$offset-1), index.cp, rep(FALSE, obj$sw-obj$offset))

  inon_na <- index.cp

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "hcp_scp"

  return(detection)
}
