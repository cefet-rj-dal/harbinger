#'@title Anomaly and change point detector using RED
#'@description Anomaly and change point detection using RED
#'The RED model adjusts to the time series. Observations distant from the model are labeled as anomalies.
#'It wraps the EMD model presented in the hht library.
#'@param noise nosie
#'@param trials trials
#'@param red_cp red change point
#'@param volatility_cp volatility change point
#'@param trend_cp trend change point
#'@return `hanr_emd` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
#'head(dataset)
#'
#'# setting up time series emd detector
#'model <- hanr_emd()
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
hanr_red <- function(noise = 0.001, trials = 5, red_cp = TRUE, volatility_cp = TRUE, trend_cp = TRUE) {
  obj <- harbinger()
  obj$noise <- noise
  obj$trials <- trials
  obj$red_cp <- red_cp
  obj$volatility_cp <- volatility_cp
  obj$trend_cp <- trend_cp

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
fc_somaIMF <- function(ceemd.result, start, end){
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
#'@export
detect.hanr_red <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)
  san_size <-  length(obj$serie)

  ## calculate IMFs
  suppressWarnings(ceemd.result <- hht::CEEMD(obj$serie, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model_an <- ceemd.result

  ## create accumulate IMFs vector
  cum.vec <- list()
  for (n in 1:obj$model_an$nimf){
    cum.vec[[n]] <- fc_somaIMF(obj$model_an, 1, n)
  }

  ## calculate roughness for each imf
  vec <- vector()
  for (n in 1:length(cum.vec)){
    vec[n] <- fc(cum.vec[[n]])
  }
  ## Maximum curvature
  res <- daltoolbox::transform(daltoolbox::fit_curvature_max(), vec)
  div <- res$x

  ## ANOMALY ##
  ## adding the IMFs with the highest variance
  sum_an <- fc_somaIMF(obj$model_an, 1, div)#pra AN

  # Creates the differential of the sum_an
  diff_soma <- c(NA, diff(sum_an)) #NA no primeiro valor para mantes length da série

  ## Calculates the standard deviation of the central point.
  sd <- zoo::rollapply(serie, 30, sd, by = 1) # I set the window to 30.
  sd <- c(rep(NA,14),sd,rep(NA,15)) #filling the borders with NA.

  ## Creating anomaly vector.
  anoms <- diff_soma/sd

  ## determining outliers according to criterion 2.698 x standard deviation.
  outliers <- which(abs(anoms) > 2.698*sd(anoms, na.rm=TRUE))

  # removing duplicate anomalies
  # captures and stores all sequences
  group_an <- split(outliers, cumsum(c(1, diff(outliers) != 1)))

  an <- rep(FALSE, length(serie))
  ## removes the first point from the sequences.
  for (g in group_an) {
    if (length(g) > 0) {
      i <- min(g)
      an[i] <- TRUE
    }
  }

  i_an <- which(an, arr.ind = TRUE)

  anomalies <- rep(FALSE, length(serie))
  if (!is.null(i_an) & length(i_an) > 0) {
    anomalies[i_an] <- TRUE
  }


  ## CHANGE POINT ##

  serie2 <- serie
  serie2[i_an] <- NA
  no_na <- which(!is.na(serie2))
  serie_cp <- serie2[!is.na(serie2)]

  id <- 1:length(serie_cp)

  ## calculate IMFs
  suppressWarnings(ceemd.result <- hht::CEEMD(serie_cp, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model_cp <- ceemd.result

  ## CP do hanr_red
  cp_hanr_red <- vector()
  if(obj$red_cp==TRUE){
    soma_cp <- vector()

    if(div<obj$model_cp$nimf){#This if checks if there is an IMF larger than the division
      #adding the IMFs of low variance
      soma_cp <- fc_somaIMF(obj$model_cp, div+1, obj$model_cp$nimf)
    }

    #resuming the positions of the original series
    i <- rep(NA, san_size)
    i[no_na] <- soma_cp

    #change points according to criterion 2.698 x standard deviation
    cp_hanr_red <- which(abs(soma_cp)>2.698*sd(soma_cp, na.rm=TRUE))
    cp_hanr_red <- median_point(cp_hanr_red)
  }

  ## Volatility CP (Change Points)
  cp_volatility <- vector()
  if(obj$volatility_cp==TRUE){
    sd2 <- zoo::rollapply(serie_cp, 30, sd, by = 1)
    sd2 <- c(rep(NA,14),sd2,rep(NA,15))
    sd3 <- zoo::rollapply(sd2, 30, sd, by = 1)
    sd3 <- c(rep(NA,14),sd3,rep(NA,15))

    ## resuming the positions of the original series
    i <- rep(NA, san_size)
    i[no_na] <- sd3

    cp_volatility <- which(abs(sd3) > 2.698*sd(sd3, na.rm=TRUE))
    cp_volatility <- median_point(cp_volatility)
  }

    ## Trend CP (Change Points)
    cp_trend <- vector()
    if(obj$trend_cp==TRUE){

      i <- obj$model_an$residue

      modelo <- fit(hcp_gft(), i)
      cp_trend <- detect(modelo, i)
      cp_trend <- which(cp_trend$event==TRUE)
    }

    ## merging the Change Points
    cps <- c(cp_hanr_red, cp_volatility, cp_trend)

    change_points <- rep(FALSE, length(serie))
    if (!is.null(cps) & length(cps) > 0) {
      change_points[cps] <- TRUE
    }

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, change_points = change_points)

  return(detection)
}

