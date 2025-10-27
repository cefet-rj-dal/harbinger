#'@title Chow Test (structural break)
#'@description Change-point detection for linear models using F-based structural break tests from the strucchange package <doi:10.18637/jss.v007.i02>.
#'It wraps the Fstats and breakpoints implementation available in the strucchange library.
#A. Zeileis, C. Kleiber, W. Krämer, and K. Hornik, 2003, Testing and dating of structural changes in practice, Computational Statistics & Data Analysis, v. 44, n. 1 (Oct.), p. 109–123.
#A. Zeileis, F. Leisch, K. Hornik, and C. Kleiber 2002.  Strucchange: An R package for testing for structural change in linear regression models.
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
