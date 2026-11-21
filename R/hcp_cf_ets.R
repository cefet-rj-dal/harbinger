#' @title Change Finder (robust), discounted Holt -- "++" re-implementation
#' @description
#' Change-point detection with a native, self-contained robust ChangeFinder (no
#' `forecast` dependency). This is an \strong{adaptation} of the original
#' ChangeFinder-ETS with documented innovations: instead of scoring
#' `forecast::ets` residuals, it implements the canonical two-stage online
#' ChangeFinder of Takeuchi & Yamanishi (2006) with a \emph{discounted Holt}
#' (level+trend, the exponential-smoothing analogue of SDAR) predictor, and takes
#' the \strong{union} with a Gaussian mean+variance structural break (shared with
#' `hcp_chow`/`hcp_gft`), which recovers smooth trend/slope changes the surprise
#' score is blind to.
#'
#' This mirrors the canonical implementation in the `pyharbinger` package (class
#' `HcpCfEts`); the two implementations produce identical detections.
#'
#' @param sw_size Integer. Smoothing window for the two-stage scores / warm-up.
#' @param alpha Holt level smoothing factor.
#' @param beta Holt trend smoothing factor.
#' @param r Forgetting (discounting) factor for the residual variance.
#' @param h Minimal segment fraction for the mean+variance structural break.
#' @return `hcp_cf_ets` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load change-point example data
#' data(examples_changepoints)
#'
#' # Use a simple example
#' dataset <- examples_changepoints$simple
#' head(dataset)
#'
#' # Configure ChangeFinder-ETS detector
#' model <- hcp_cf_ets()
#'
#' # Fit the model (no-op; detection is self-contained)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#' @references
#' - Takeuchi J, Yamanishi K (2006). A unifying framework for detecting outliers and
#'   change points from time series. IEEE Transactions on Knowledge and Data
#'   Engineering, 18(4):482-492.
#' - Holt CC (1957/2004). Forecasting seasonals and trends by exponentially weighted
#'   moving averages. International Journal of Forecasting, 20(1):5-10.
#' - Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis. Birkhauser.
#'
#' @export
hcp_cf_ets <- function(sw_size = 5, alpha = 0.8, beta = 0.1, r = 0.05, h = 0.15) {
  obj <- harbinger()
  obj$sw_size <- sw_size
  obj$alpha <- alpha
  obj$beta <- beta
  obj$r <- r
  obj$h <- h
  class(obj) <- append("hcp_cf_ets", class(obj))
  return(obj)
}

#'@exportS3Method detect hcp_cf_ets
detect.hcp_cf_ets <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)
  x <- obj$serie

  score_fn <- function(z) .har_sdar_holt_scores(z, obj$alpha, obj$beta, obj$r)
  out <- .har_robust_changefinder(obj, x, obj$sw_size, obj$h, score_fn)

  detection <- obj$har_restore_refs(
    obj, anomalies = out$anomalies, change_points = out$cp, res = out$cp_score
  )
  return(detection)
}
