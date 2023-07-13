#'@title Anomaly detector using Garch
#'@description Anomaly detector using Garch
#'@param w Window size for warm-up garch
#'@return hanr_garch object
#'@examples detector <- harbinger()
#'@export
hanr_garch <- function(w = 5) {
  obj <- harbinger()

  obj$w <- w

  class(obj) <- append("hanr_garch", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom rugarch ugarchspec
#'@importFrom rugarch ugarchfit
#'@export
detect.hanr_garch <- function(obj, serie, ...) {
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie <- stats::na.omit(serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                                 mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                                 distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  s <- obj$har_residuals(model$sigma)
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers[1:obj$w] <- FALSE
  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "anomaly"

  return(detection)
}

