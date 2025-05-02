#'@title Change Finder using GARCH
#'@description Change-point detection is related to event/trend change detection. Change Finder GARCH detects change points based on deviations relative to linear regression model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the GARCH model presented in the rugarch library.
#'@param sw_size Sliding window size
#'@return `hcp_garch` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_changepoints)
#'
#'#Using volatility example
#'dataset <- examples_changepoints$volatility
#'head(dataset)
#'
#'# setting up change point method
#'model <- hcp_garch()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hcp_garch <- function(sw_size = 5) {
  obj <- harbinger()
  obj$sw_size <- sw_size

  hutils <- harutils()
  obj$har_outliers_check <- hutils$har_outliers_checks_highgroup

  class(obj) <- append("hcp_garch", class(obj))
  return(obj)
}

#'@importFrom stats lm
#'@importFrom stats na.omit
#'@importFrom stats residuals
#'@importFrom rugarch ugarchspec
#'@importFrom rugarch ugarchfit
#'@exportS3Method detect hcp_garch
detect.hcp_garch <- function(obj, serie, ...) {
  linreg <- function(serie) {
    data <- data.frame(t = 1:length(serie), x = serie)
    return(stats::lm(x~t, data))
  }

  obj <- obj$har_store_refs(obj, serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                              mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                              distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=obj$serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  y <- model$sigma

  #Adjusting a model to the entire series
  #Adjusting to the entire series
  M2 <- linreg(y)

  #Adjustment error on the whole window
  u <- obj$har_distance(stats::residuals(M2))
  u <- mas(u, obj$sw_size)
  cp <- obj$har_outliers(u)
  cp <- obj$har_outliers_check(cp, u)

  cp[1:obj$sw_size] <- FALSE
  cp <- c(rep(FALSE, length(y)-length(u)), cp)

  detection <- obj$har_restore_refs(obj, change_points = cp, res = u)

  return(detection)
}

