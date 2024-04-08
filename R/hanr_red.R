#'@title Anomaly and change point detector using RED
#'@description Anomaly and change point detection using RED
#'The RED model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the EMD model presented in the hht library.
#'@param sw_size sliding window size (default 30)
#'@param noise noise
#'@param trials trials
#'@return `hanr_red` object
#'@examples
#'library(daltoolbox)
#'library(zoo)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
#'head(dataset)
#'
#'# setting up time series emd detector
#'model <- hanr_red()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hanr_red <- function(sw_size = 30, noise = 0.001, trials = 5) {
  obj <- harbinger()
  obj$sw_size <- sw_size
  obj$noise <- noise
  obj$trials <- trials

  class(obj) <- append("hanr_red", class(obj))
  return(obj)
}

## Roughness function
#'@importFrom stats sd
fc <- function(x){
  firstD = base::diff(x)
  normFirstD = (firstD - base::mean(firstD)) / stats::sd(firstD)
  roughness = (base::diff(normFirstD) ** 2) / 4
  return(base::mean(roughness))
}

## Function that sums the IMFs given an initial and final IMF.
fc_sumIMF <- function(ceemd.result, start, end){
  soma_imf <- base::rep(0, length(ceemd.result[["original.signal"]]))
  for (k in start:end){
    soma_imf <- soma_imf + ceemd.result[["imf"]][,k]
  }
  return(soma_imf)
}

## Function that calculates the central point of the sequences.
median_point <- function(cp){
  group_outliers <- base::split(cp, base::cumsum(c(1, base::diff(cp) != 1)))

  cp <- base::rep(FALSE, length(cp))

  # removes the central point from the sequences
  for (g in group_outliers) {
    if (length(g) > 0) {
      j <- stats::median(g)
      cp[j] <- TRUE
    }
  }

  i_cp <- base::which(cp, arr.ind = TRUE)
  i_cp
}


#'@importFrom stats median
#'@importFrom stats sd
#'@importFrom hht CEEMD
#'@importFrom zoo rollapply
#'@importFrom daltoolbox transform
#'@importFrom daltoolbox fit_curvature_max
#'@export
detect.hanr_red <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)
  san_size <- length(obj$serie)

  ## calculate IMFs
  suppressWarnings(ceemd.result <- hht::CEEMD(obj$serie, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model_an <- ceemd.result

  ## create accumulate IMFs vector
  cum.vec <- list()
  for (n in 1:obj$model_an$nimf){
    cum.vec[[n]] <- fc_sumIMF(obj$model_an, 1, n)
  }

  ## calculate roughness for each imf
  vec <- vector()
  for (n in 1:length(cum.vec)){
    vec[n] <- fc(cum.vec[[n]])
  }

  div <- 1
  if (length(cum.vec) > 1) {
    ## Maximum curvature
    res <- daltoolbox::transform(daltoolbox::fit_curvature_max(), vec)
    div <- res$x
  }

  ## ANOMALY ##
  ## adding the IMFs with the highest variance
  sum_an <- fc_sumIMF(obj$model_an, 1, div) # for AN

  # Creates the differential of the sum_an
  sum_diff <- c(NA, diff(sum_an)) #NA in the first value to maintain the length of the series

  ## Calculates the standard deviation of the central point.
  sd <- zoo::rollapply(obj$serie, obj$sw_size, sd, by = 1)
  sd <- c(rep(NA,14), sd, rep(NA,15)) #filling the borders with NA.

  ## Creating anomaly vector.
  anoms <- sum_diff/sd

  ## determining outliers according to criterion 2.698 x standard deviation.
  outliers <- which(abs(anoms) > 2.698*sd(anoms, na.rm=TRUE))

  # removing duplicate anomalies
  # captures and stores all sequences
  group_an <- split(outliers, cumsum(c(1, diff(outliers) != 1)))

  an <- rep(FALSE, length(obj$serie))
  ## removes the first point from the sequences.
  for (g in group_an) {
    if (length(g) > 0) {
      i <- min(g)
      an[i] <- TRUE
    }
  }

  i_an <- which(an, arr.ind = TRUE)

  anomalies <- rep(FALSE, length(obj$serie))
  if (!is.null(i_an) & length(i_an) > 0) {
    anomalies[i_an] <- TRUE
  }

  detection <- obj$har_restore_refs(obj, anomalies = anomalies)

  return(detection)
}

