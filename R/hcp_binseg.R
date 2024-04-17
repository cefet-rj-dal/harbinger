#'@title Binary segmentation (BinSeg) method
#'@description Change-point detection method that focus on identify change points in mean/variance <doi:10.2307/2529204>.
#'It wraps the BinSeg implementation available in the changepoint library.
#'@param Q The maximum number of change-points to search for using the BinSeg method
#Binary Segmentation: Scott, A. J. and Knott, M. (1974) A Cluster Analysis Method for Grouping Means in the Analysis of Variance, Biometrics 30(3), 507–512
#'@return `hcp_binseg` object
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
#'# setting up change point method
#'model <- hcp_binseg()
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
hcp_binseg <- function(Q = 2) {
  obj <- harbinger()
  obj$Q <- Q
  class(obj) <- append("hcp_binseg", class(obj))
  return(obj)
}

#'@importFrom changepoint cpt.meanvar
#'@export
detect.hcp_binseg <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  # Perform change point detection using Binary Segmentation
  cpt_result <- cpt.meanvar(obj$serie, method = "BinSeg", Q = obj$Q)

  cp <- rep(FALSE, length(obj$serie))
  n <- length(cpt_result@cpts)
  if (n > 1)
    cp[cpt_result@cpts[1:(n-1)]] <- TRUE

  detection <- obj$har_restore_refs(obj, change_points = cp)

  return(detection)
}
