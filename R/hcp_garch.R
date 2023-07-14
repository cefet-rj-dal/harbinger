#'@title Change Finder using GARCH
#'@description Change-point detection is related to event/trend change detection. Change Finder GARCH detects change points based on deviations relative to linear regression model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the GARCH model presented in the rugarch library.
#'@param sw_size Sliding window size
#'@return `hcp_garch` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 14
#'dataset <- har_examples$example14
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hcp_garch()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection |> dplyr::filter(event==TRUE))
#'
#'@export
hcp_garch <- function(sw_size = 30) {
  obj <- harbinger()
  obj$sw_size <- sw_size

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
  outliers <- obj$har_outliers_idx(s)
  outliers <- obj$har_outliers_group(outliers, length(s))

  outliers[1:obj$sw_size] <- FALSE

  i_outliers <- rep(NA, n)
  i_outliers[non_na] <- outliers

  detection <- data.frame(idx=1:n, event = i_outliers, type="")
  detection$type[i_outliers] <- "changepoint"
  detection$event[i_outliers] <- TRUE

  return(detection)
}

