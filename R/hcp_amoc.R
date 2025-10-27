#' @title At Most One Change (AMOC)
#' @description
#' Change-point detection method focusing on identifying at most one change in
#' mean and/or variance. This is a wrapper around the AMOC implementation from
#' the `changepoint` package.
#'
#' @details
#' AMOC detects a single most significant change point under a cost function
#' optimized for a univariate series. It is useful when at most one structural
#' break is expected.
#'
#' @return `hcp_amoc` object.
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
#' # Configure the AMOC detector
#' model <- hcp_amoc()
#'
#' # Fit the detector (no-op for AMOC)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change point(s)
#' print(detection[(detection$event),])
#'
#' @references
#' - Hinkley DV (1970). Inference about the change-point in a sequence of random variables. Biometrika, 57(1):1–17. doi:10.1093/biomet/57.1.1
#' - Killick R, Fearnhead P, Eckley IA (2012). Optimal detection of changepoints with a linear computational cost. JASA, 107(500):1590–1598.
#'
#' @export
hcp_amoc <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_amoc", class(obj))
  return(obj)
}

#' @importFrom changepoint cpt.meanvar
#' @exportS3Method detect hcp_amoc
detect.hcp_amoc <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Run AMOC on mean/variance
  cpt_result <- changepoint::cpt.meanvar(obj$serie, method = "AMOC", penalty="MBIC", test.stat="Normal")

  # Convert breakpoints to boolean vector
  cp <- rep(FALSE, length(obj$serie))
  n <- length(cpt_result@cpts)
  if (n > 1)
    cp[cpt_result@cpts[1:(n-1)]] <- TRUE

  # Restore to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
