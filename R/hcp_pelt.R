#' @title Pruned Exact Linear Time (PELT)
#' @description
#' Multiple change-point detection using the PELT algorithm for mean/variance
#' with a linear-time cost under suitable penalty choices. This function wraps
#' the PELT implementation in the `changepoint` package.
#'
#' @details
#' PELT performs optimal partitioning while pruning candidate change-point
#' locations to achieve near-linear computational cost.
#'
#' @return `hcp_pelt` object.
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
#' # Configure the PELT detector
#' model <- hcp_pelt()
#'
#' # Fit the detector (no-op for PELT)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#' @references
#' - Killick R, Fearnhead P, Eckley IA (2012). Optimal detection of changepoints
#'   with a linear computational cost. JASA, 107(500):1590–1598.
#'
#' @export
hcp_pelt <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_pelt", class(obj))
  return(obj)
}

#' @importFrom changepoint cpt.meanvar
#' @exportS3Method detect hcp_pelt
detect.hcp_pelt <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Run PELT on mean/variance
  cpt_result <- cpt.meanvar(obj$serie, method = "PELT", test.stat = "Normal", pen.value = "MBIC")

  # Convert breakpoints to boolean vector
  cp <- rep(FALSE, length(obj$serie))
  n <- length(cpt_result@cpts)
  if (n > 1)
    cp[cpt_result@cpts[1:(n-1)]] <- TRUE

  # Restore to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
