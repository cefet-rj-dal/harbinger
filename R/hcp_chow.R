#'@title Chow Test (structural break)
#'@description Change-point detection for linear models using F-based structural
#'break tests from the `strucchange` package <doi:10.18637/jss.v007.i02>.
#'Wraps the `Fstats` and `breakpoints` implementations from the `strucchange` package.
#'@return `hcp_chow` object
#'@examples
#'library(daltoolbox)
#'
#' # Load change-point example data
#' data(examples_changepoints)
#'
#' # Use a simple example
#' dataset <- examples_changepoints$simple
#' head(dataset)
#'
#' # Configure the Chow detector
#' model <- hcp_chow()
#'
#' # Fit the detector (no-op for Chow)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#'@export
hcp_chow <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_chow", class(obj))
  return(obj)
}

#'@importFrom strucchange Fstats
#'@importFrom strucchange breakpoints
#'@exportS3Method detect hcp_chow
detect.hcp_chow <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  y <- obj$serie
  x <- 1:length(y)

  # Perform using f-test
  model <- strucchange::Fstats(y ~ x)
  breaks <- strucchange::breakpoints(model)

  # Convert breakpoints to boolean vector
  cp <- rep(FALSE, length(obj$serie))
  n <- length(breaks$breakpoints)
  if (n > 0)
    cp[breaks$breakpoints] <- TRUE

  # Restore to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
