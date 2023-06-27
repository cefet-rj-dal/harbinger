#'@title Anomaly detector based on machine learning classification
#'@description Anomaly detector based on machine learning classification
#'@param model DAL Classification Model
#'@param tune DAL Tune Model
#'@param alpha Outliers threshold
#'@return hanc_ml object
#'@examples detector <- harbinger()
#'@export
hanc_ml <- function(model, tune = NULL, alpha = 1.5) {
  obj <- harbinger()
  obj$model <- model
  obj$alpha <- alpha
  obj$tune <- tune
  class(obj) <- append("hanc_ml", class(obj))
  return(obj)
}

#'@import daltoolbox
#'@export
fit.hanc_ml <- function(obj, serie, ...) {
  obj$model <- daltoolbox::fit(obj$model, serie)
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stats predict
#'@export
detect.hanc_ml <- function(obj, serie, ...) {
  n <- nrow(serie)
  non_na <- which(!is.na(apply(serie, 1, max)))
  serie <- stats::na.omit(serie)

  adjust <- stats::predict(obj$model, serie)
  outliers <- which(adjust[,1] < adjust[,2])
  group_outliers <- split(outliers, cumsum(c(1, diff(outliers) != 1)))
  outliers <- rep(FALSE, nrow(serie))
  for (g in group_outliers) {
    if (length(g) > 0) {
      i <- min(g)
      outliers[i] <- TRUE
    }
  }
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}
