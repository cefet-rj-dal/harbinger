#'@title Chow test method
#'@description Change-point detection method that focus on identifying structural changes  <doi:10.18637/jss.v007.i02>.
#'It wraps the Fstats and breakpoints implementation available in the strucchange library.
#A. Zeileis, C. Kleiber, W. Krämer, and K. Hornik, 2003, Testing and dating of structural changes in practice, Computational Statistics & Data Analysis, v. 44, n. 1 (Oct.), p. 109–123.
#A. Zeileis, F. Leisch, K. Hornik, and C. Kleiber 2002.  Strucchange: An R package for testing for structural change in linear regression models.
#'@return `hcp_chow` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 6
#'dataset <- har_examples$example6
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hcp_chow()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
#'# execute the detection method
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hcp_chow <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_chow", class(obj))
  return(obj)
}

#'@importFrom strucchange Fstats
#'@importFrom strucchange breakpoints
#'@export
detect.hcp_chow <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  y <- obj$serie
  x <- 1:length(y)

  # Perform using f-test
  model <- strucchange::Fstats(y ~ x)
  breaks <- strucchange::breakpoints(model)

  cp <- rep(FALSE, length(obj$serie))
  n <- length(breaks$breakpoints)
  if (n > 0)
    cp[breaks$breakpoints] <- TRUE

  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
