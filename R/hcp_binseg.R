#' @title Binary Segmentation (BinSeg)
#' @description
#' Multi-change-point detection via Binary Segmentation on mean/variance using
#' the `changepoint` package.
#'
#' @details
#' Binary Segmentation recursively partitions the series around the largest
#' detected change until a maximum number of change points or stopping criterion
#' is met. This is a fast heuristic widely used in practice.
#'
#' @param Q Integer. Maximum number of change points to search for.
#' @return `hcp_binseg` object.
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
#' # Configure the BinSeg detector
#' model <- hcp_binseg()
#'
#' # Fit the detector (no-op for BinSeg)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#' @references
#' - Vostrikova L (1981). Detecting "disorder" in multidimensional random processes. Soviet Mathematics Doklady, 24, 55–59.
#' - Killick R, Fearnhead P, Eckley IA (2012). Optimal detection of changepoints with a linear computational cost. JASA, 107(500):1590–1598. [context]
#'
#' @export
hcp_binseg <- function(Q = 2) {
  obj <- harbinger()
  obj$Q <- Q
  class(obj) <- append("hcp_binseg", class(obj))
  return(obj)
}

#' @importFrom changepoint cpt.meanvar
#' @exportS3Method detect hcp_binseg
detect.hcp_binseg <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  # Perform change point detection using Binary Segmentation
  cpt_result <- cpt.meanvar(obj$serie, method = "BinSeg", Q = obj$Q)

  # Convert breakpoints to boolean vector
  cp <- rep(FALSE, length(obj$serie))
  n <- length(cpt_result@cpts)
  if (n > 1)
    cp[cpt_result@cpts[1:(n-1)]] <- TRUE

  # Restore to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
