#' @title Generalized Fluctuation Test (GFT)
#' @description
#' Structural change detection using generalized fluctuation tests via
#' `strucchange::breakpoints()` <doi:10.18637/jss.v007.i02>.
#A. Zeileis, C. Kleiber, W. Krämer, and K. Hornik, 2003, Testing and dating of structural changes in practice, Computational Statistics & Data Analysis, v. 44, n. 1 (Oct.), p. 109–123.
#A. Zeileis, F. Leisch, K. Hornik, and C. Kleiber 2002.  Strucchange: An R package for testing for structural change in linear regression models.
#' @return `hcp_gft` object
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
#' # Configure the GFT detector
#' model <- hcp_gft()
#'
#' # Fit the detector (no-op for GFT)
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected change points
#' print(detection[(detection$event),])
#'
#' @references
#' - Zeileis A, Leisch F, Kleiber C, Hornik K (2002). strucchange: An R package for testing
#'   for structural change in linear regression models. Journal of Statistical Software, 7(2). doi:10.18637/jss.v007.i02
#' - Zeileis A, Kleiber C, Krämer W, Hornik K (2003). Testing and dating of structural
#'   changes in practice. Computational Statistics & Data Analysis, 44(1):109–123.
#'
#' @export
hcp_gft <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_gft", class(obj))
  return(obj)
}

#'@importFrom strucchange Fstats
#'@importFrom strucchange breakpoints
#'@exportS3Method detect hcp_gft
detect.hcp_gft <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  y <- obj$serie
  x <- 1:length(y)

  # Fit breakpoints on linear model residual patterns
  breaks <- breakpoints(y ~ x)

  cp <- rep(FALSE, length(obj$serie))
  n <- length(breaks$breakpoints)
  if (n > 0)
    cp[breaks$breakpoints] <- TRUE

  # Restore change points to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
