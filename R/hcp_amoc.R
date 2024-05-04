#'@title At most one change (AMOC) method
#'@description Change-point detection method that focus on identify one change point in mean/variance <doi:10.1093/biomet/57.1.1>.
#'It wraps the amoc implementation available in the changepoint library.
#Hinkley, D. V. Inference about the change-point in a sequence of random variables. Biometrika, 57(1):1–17, 1970
#'@return `hcp_amoc` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_changepoints)
#'
#'#Using simple example
#'dataset <- examples_changepoints$simple
#'head(dataset)
#'
#'# setting up change point method
#'model <- hcp_amoc()
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
hcp_amoc <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_amoc", class(obj))
  return(obj)
}

#'@importFrom changepoint cpt.meanvar
#'@export
detect.hcp_amoc <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  cpt_result <- changepoint::cpt.meanvar(obj$serie, method = "AMOC", penalty="MBIC", test.stat="Normal")

  cp <- rep(FALSE, length(obj$serie))
  n <- length(cpt_result@cpts)
  if (n > 1)
    cp[cpt_result@cpts[1:(n-1)]] <- TRUE

  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
