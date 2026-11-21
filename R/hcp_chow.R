#'@title Chow Test (structural break), scale-aware re-implementation
#'@description
#'Change-point detection by structural break in a linear model. This is a native
#'re-implementation (no \code{strucchange} dependency) and an \strong{adaptation}
#'of the original Chow/\code{strucchange} approach with a documented innovation:
#'where the classical Chow test only compares the \emph{mean} regression
#'coefficients of the two sub-samples (homoskedastic errors), this version reports
#'the single break that maximises the Gaussian \emph{mean + variance}
#'log-likelihood ratio over an unknown break date. It is therefore scale-aware --
#'it also detects variance/scale regime changes the mean-only Chow test is blind
#'to. The break is scanned over the trimmed range following the sup-type
#'construction of Andrews (1993).
#'
#'This mirrors the canonical implementation in the \code{pyharbinger} package
#'(class \code{HcpChow}); the two implementations produce identical detections.
#'@return \code{hcp_chow} object
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
#'@references
#' - Chow GC (1960). Tests of equality between sets of coefficients in two linear
#'   regressions. Econometrica, 28(3):591-605.
#' - Andrews DWK (1993). Tests for parameter instability and structural change
#'   with unknown change point. Econometrica, 61(4):821-856.
#' - Chen J, Gupta AK (2000). Parametric Statistical Change Point Analysis.
#'   Birkhauser. (Gaussian mean+variance change points)
#' - Zeileis A, Leisch F, Hornik K, Kleiber C (2002). strucchange: An R package
#'   for testing for structural change in linear regression models. Journal of
#'   Statistical Software, 7(2). doi:10.18637/jss.v007.i02 (original approach)
#'
#'@export
hcp_chow <- function() {
  obj <- harbinger()
  obj$h <- 0.15
  class(obj) <- append("hcp_chow", class(obj))
  return(obj)
}

#'@exportS3Method detect hcp_chow
detect.hcp_chow <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  # Normalize indexing and omit NAs
  obj <- obj$har_store_refs(obj, serie)

  y <- obj$serie

  # Single break maximising the Gaussian mean+variance log-likelihood ratio.
  bp <- .har_meanvar_single_break(y, obj$h)

  # Convert breakpoint to boolean vector
  cp <- rep(FALSE, length(obj$serie))
  if (!is.null(bp))
    cp[bp] <- TRUE

  # Restore to original indexing
  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
