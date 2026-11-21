#' @title Bayesian Online Change Point Detection -- "++" re-implementation
#' @description
#' Change-point detection with a native, self-contained Bayesian Online Change
#' Point Detector (no `ocp` dependency). This is an \strong{adaptation} of BOCPD
#' (Adams & MacKay 2007) with documented innovations over the `ocp` backend:
#'
#' \enumerate{
#'   \item \strong{Autoregressive UPM.} `ocp` uses an i.i.d. Gaussian underlying
#'     predictive model, which only sees shifts in level and variance. Here the
#'     per-run-length model is a conjugate \emph{Bayesian linear autoregression}
#'     (a regression of x_t on `[1, x_{t-1}, ...]`, Normal-Inverse-Gamma prior,
#'     Student-t predictive), so it also detects changes in dynamics (slope,
#'     trend, autocorrelation).
#'   \item \strong{Log-space + eps-pruning.} The run-length recursion runs in
#'     log-space and the run-length distribution is pruned to the entries holding
#'     all but a fraction `prune_eps` of the peak mass -- a bounded-state,
#'     streaming recursion.
#'   \item \strong{Surprise-based extraction.} Change points are read from the
#'     Bayesian predictive surprise `-log p(x_t | x_{1:t-1})` via a causal robust
#'     local z-score, replacing `ocp`'s noisy three-list voting.
#' }
#'
#' This mirrors the canonical implementation in the `pyharbinger` package (class
#' `HcpBocpd`); the two implementations produce identical detections.
#'
#' @param hazard Positive scalar; the prior change probability per step is
#'   `1 / hazard`.
#' @param threshold Local z-score a surprise peak must reach to be flagged.
#' @param min_distance Minimum distance between selected change points.
#' @param burn_in Number of initial observations to ignore.
#' @param order Autoregressive order of the UPM (regressors `[1, x_{t-1}, ...]`).
#' @param local_window Trailing window of the robust local z-score baseline.
#' @param prune_eps Run lengths below `prune_eps` times the peak mass are pruned.
#' @return An `hcp_bocpd` object.
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
#' # Configure BOCPD detector
#' model <- hcp_bocpd()
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
#' - Adams RP, MacKay DJC (2007). Bayesian Online Changepoint Detection.
#'   arXiv:0710.3742.
#' - Fearnhead P, Liu Z (2007). On-line inference for multiple changepoint
#'   problems. J. R. Stat. Soc. B, 69(4):589-605. (online inference with
#'   resampling/pruning of the run-length distribution; segment regression models)
#' - Fearnhead P (2006). Exact and efficient Bayesian inference for multiple
#'   changepoint problems. Statistics and Computing, 16(2):203-213. (Bayesian
#'   linear-regression segment models)
#' - Saatci Y, Turner R, Rasmussen CE (2010). Gaussian Process Change Point
#'   Models. ICML. (BOCPD with richer predictive models and run-length pruning)
#' - Takeuchi J, Yamanishi K (2006). A unifying framework for detecting outliers
#'   and change points from time series. IEEE TKDE, 18(4):482-492.
#'   (autoregressive change-point surprise)
#'
#' @export
hcp_bocpd <- function(
    hazard = 250,
    threshold = 6,
    min_distance = 15,
    burn_in = 5,
    order = 1,
    local_window = 20,
    prune_eps = 1e-6
) {
  obj <- harbinger()
  obj$hazard <- hazard
  obj$threshold <- threshold
  obj$min_distance <- min_distance
  obj$burn_in <- burn_in
  obj$order <- order
  obj$local_window <- local_window
  obj$prune_eps <- prune_eps
  class(obj) <- append("hcp_bocpd", class(obj))
  obj
}

#' @exportS3Method detect hcp_bocpd
detect.hcp_bocpd <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)
  x <- obj$serie

  surprise <- .har_bocpd_ar_surprise(
    x, order = obj$order, hazard = obj$hazard,
    lam0 = 0.1, a0 = 1, b0 = 1e-2, prune_eps = obj$prune_eps
  )
  score <- .har_bocpd_local_z(surprise, obj$local_window)
  event <- .har_bocpd_peaks(score, obj$threshold, obj$min_distance, obj$burn_in)

  detection <- obj$har_restore_refs(obj, change_points = event, res = score)
  detection
}
