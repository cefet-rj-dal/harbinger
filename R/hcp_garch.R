#'@title Change Finder using GARCH
#'@description Change Finder using GARCH
#'@param w Sliding window size
#'@param alpha Threshold for outliers
#'@return hcp_garch object
#'@examples detector <- harbinger()
#'@export
hcp_garch <- function(w = 30, alpha = 1.5) {
  obj <- harbinger()
  obj$w <- w
  obj$alpha <- alpha
  class(obj) <- append("hcp_garch", class(obj))
  return(obj)
}

#'@importFrom stats lm
#'@importFrom stats na.omit
#'@importFrom stats residuals
#'@importFrom rugarch ugarchspec
#'@importFrom rugarch ugarchfit
#'@export
detect.hcp_garch <- function(obj, serie, ...) {
  linreg <- function(serie) {
    data <- data.frame(t = 1:length(serie), x = serie)
    return(stats::lm(x~t, data))
  }

  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- stats::na.omit(serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                              mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                              distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  serie <- model$sigma


  #Adjusting a model to the entire series
  M1 <- linreg(serie)

  #Adjustment error on the entire series
  s <- obj$har_residuals(stats::residuals(M1))
  outliers <- obj$har_outliers_idx(s, alpha = obj$alpha)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers[1:obj$w] <- FALSE

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "changepoint"
  detection$event[i_outliers] <- TRUE

  return(detection)
}

