#'@title Anomaly detector using machine learning regression
#'@description Anomaly detector using machine learning regression
#'@param model DAL Toolbox regression model
#'@param tune DAL Toolbox tunel
#'@param sw_size Sliding window size
#'@param alpha Threshold for outliers
#'@return hanr_ml object
#'@examples detector <- harbinger()
#'@export
hanr_ml <- function(model, tune = NULL, sw_size = 15, alpha = 1.5) {
  obj <- harbinger()
  obj$model <- model
  obj$sw_size <- sw_size
  obj$alpha <- alpha
  obj$tune <- tune
  class(obj) <- append("hanr_ml", class(obj))
  return(obj)
}

#'@export
fit.hanr_ml <- function(obj, serie, ...) {
  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  obj$model <- fit(obj$model, x=io$input, y=io$output)

  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats predict
#'@export
detect.hanr_ml <- function(obj, serie, ...) {
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  ts <- ts_data(serie, obj$sw_size)
  io <- ts_projection(ts)

  adjust <- stats::predict(obj$model, io$input)
  s <- abs(io$output-adjust)
  outliers <- har_outliers_idx(s)
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, length(s))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  outliers <- c(rep(NA, obj$sw_size - 1), outliers)
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}
