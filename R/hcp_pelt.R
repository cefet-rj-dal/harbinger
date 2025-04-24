#'@title Pruned exact linear time (PELT) method
#'@description Change-point detection method that focus on identifying multiple exact change points in mean/variance <doi:10.1080/01621459.2012.737745>.
#'It wraps the BinSeg implementation available in the changepoint library.
#PELT Algorithm: Killick R, Fearnhead P, Eckley IA (2012) Optimal detection of changepoints with a linear computational cost, JASA 107(500), 1590–1598
#'@return `hcp_pelt` object
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
#'model <- hcp_pelt()
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
hcp_pelt <- function() {
  obj <- harbinger()
  class(obj) <- append("hcp_pelt", class(obj))
  return(obj)
}

#'@importFrom changepoint cpt.meanvar
#'@exportS3Method detect hcp_pelt
detect.hcp_pelt <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  cpt_result <- cpt.meanvar(obj$serie, method = "PELT", test.stat = "Normal", pen.value = "MBIC")

  cp <- rep(FALSE, length(obj$serie))
  n <- length(cpt_result@cpts)
  if (n > 1)
    cp[cpt_result@cpts[1:(n-1)]] <- TRUE

  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
