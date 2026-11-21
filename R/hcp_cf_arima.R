#' @title Change Finder (robust), autoregressive SDAR -- "++" re-implementation
#' @description
#' Change-point detection with a native, self-contained robust ChangeFinder (no
#' `forecast` dependency). This is an \strong{adaptation} of the original
#' ChangeFinder-ARIMA with documented innovations: instead of scoring
#' `forecast::auto.arima` residuals, it implements the \emph{canonical} two-stage
#' online SDAR (Sequentially Discounting AutoRegressive) ChangeFinder of Takeuchi
#' & Yamanishi (2006) -- strong on abrupt/variance/multi-change regimes -- and
#' takes the \strong{union} with a Gaussian mean+variance structural break
#' (shared with `hcp_chow`/`hcp_gft`), which recovers the smooth trend/slope
#' changes the AR-surprise score is blind to.
#'
#' This mirrors the canonical implementation in the `pyharbinger` package (class
#' `HcpCfArima`); the two implementations produce identical detections.
#'
#' @param sw_size Integer. Smoothing window for the two-stage scores / warm-up.
#' @param r SDAR forgetting (discounting) factor.
#' @param order Autoregressive order of the SDAR model.
#' @param h Minimal segment fraction for the mean+variance structural break.
#' @return `hcp_cf_arima` object.
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
#' # Configure ChangeFinder-ARIMA detector
#' model <- hcp_cf_arima()
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
#' - Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis.
#'   Birkhauser. (mean+variance structural break)
#'
#' @export
hcp_cf_arima <- function(sw_size = 5, r = 0.07, order = 1, h = 0.15) {
  obj <- harbinger()
  obj$sw_size <- sw_size
  obj$r <- r
  obj$order <- order
  obj$h <- h
  class(obj) <- append("hcp_cf_arima", class(obj))
  return(obj)
}

#'@exportS3Method detect hcp_cf_arima
detect.hcp_cf_arima <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)
  x <- obj$serie

  score_fn <- function(z) .har_sdar_ar_scores(z, obj$r, obj$order)
  out <- .har_robust_changefinder(obj, x, obj$sw_size, obj$h, score_fn)

  detection <- obj$har_restore_refs(
    obj, anomalies = out$anomalies, change_points = out$cp, res = out$cp_score
  )
  return(detection)
}
