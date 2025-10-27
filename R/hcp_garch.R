#'@title Change Finder using GARCH
#'@description Change-point detection is related to event/trend change detection. Change Finder GARCH detects change points based on deviations relative to linear regression model <doi:10.1109/TKDE.2006.1599387>.
#'It wraps the GARCH model presented in the rugarch library.
#'@param sw_size Sliding window size
#'@return `hcp_garch` object
#'@examples
#'library(daltoolbox)
#'
#' # Load change-point example data
#' data(examples_changepoints)
#'
#' # Use a volatility example
#' dataset <- examples_changepoints$volatility
#' head(dataset)
#'
#' # Configure ChangeFinder-GARCH detector
#' model <- hcp_garch()
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#'
#'@export
hcp_garch <- function(sw_size = 5) {
  obj <- harbinger()
  obj$sw_size <- sw_size

  hutils <- harutils()

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

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  spec <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                              mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                              distribution.model = "norm")

  #Adjusting a model to the entire series
  model <- rugarch::ugarchfit(spec=spec, data=obj$serie, solver="hybrid")@fit

  #Adjustment error on the entire series
  y <- residuals(model, standardize = TRUE)

  # Adjust a linear model to residuals and compute smoothed deviation
  M2 <- linreg(y)

  #Adjustment error on the whole window
  u <- obj$har_distance(stats::residuals(M2))
  u <- mas(u, obj$sw_size)
  cp <- obj$har_outliers(u)
  cp <- obj$har_outliers_check(cp, u)

  threshold <- attr(cp, "threshold")
  u <- c(rep(0, obj$sw_size - 1), u)
  cp <- c(rep(FALSE, obj$sw_size - 1), cp)
  attr(cp, "threshold") <- threshold

  # Restore change points to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp, res = u)

  return(detection)
}

