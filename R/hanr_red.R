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
#'data(examples_anomalies)
#'
#'#Using simple example
#'dataset <- examples_anomalies$simple
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

#  Roughness function
#'@importFrom stats sd
fc_rug <- function(x){
  firstD = diff(x)
  normFirstD = (firstD - mean(firstD)) / sd(firstD)
  roughness = (diff(normFirstD) ** 2) / 4
  return(mean(roughness))
}

#  Function that sums the IMFs given an initial and final IMF.
fc_somaIMF <- function(ceemd.result, inicio, fim){
  soma_imf <- rep(0, length(ceemd.result[["original.signal"]]))
  for (k in inicio:fim){
    soma_imf <- soma_imf + ceemd.result[["imf"]][,k]
  }
  return(soma_imf)
}

#'@importFrom stats median
#'@importFrom stats sd
#'@importFrom hht CEEMD
#'@importFrom zoo rollapply
#'@importFrom daltoolbox transform
#'@importFrom daltoolbox fit_curvature_max
#'@exportS3Method detect hanr_red
detect.hanr_red <- function(obj, serie, ...) {
  if (is.null(serie))
    stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  id <- 1:length(obj$serie)
  san_size <-  length(obj$serie)

  #  calculate IMFs
  suppressWarnings(ceemd.result <- hht::CEEMD(obj$serie, id, verbose = FALSE, obj$noise, obj$trials))

  model_an <- ceemd.result

  if (model_an$nimf < 4){
    soma_an <- obj$serie - model_an$residue
  }else{
    #  calculate roughness for each imf
    vec <- vector()
    for (n in 1:model_an$nimf){
      vec[n] <- fc_rug(model_an[["imf"]][,n])
    }

    #  Maximum curvature
    res <- daltoolbox::transform(daltoolbox::fit_curvature_max(), vec)
    div <- res$x

    #  somando as IMFs de maior variância
    soma_an <- fc_somaIMF(model_an, 1, div)
  }

  #Cria o diferencial da soma_an
  diff_soma <- c(NA, diff(soma_an))
  diff_soma[1] <- diff_soma[2]#repeti no primeiro termo, o segundo termo da série diferenciada


  # Tira a tendência da série original
  isEmpty <- function(x) {
    return(length(x)==0)
  }

  if(isEmpty(model_an$residue)){
    d_serie <- obj$serie
  }else{
    d_serie <- obj$serie-model_an$residue
  }

  # Calcula volatilidade instantânea
  sd <-  rollapply(d_serie, 30, sd, by = 1, partial=TRUE)

  #  Criando vetor de anomalias
  RED_transform <- diff_soma/sd

  res <- obj$har_distance(RED_transform)

  anomalies <- obj$har_outliers(res)
  anomalies <- obj$har_outliers_check(anomalies, res)

  detection <- obj$har_restore_refs(obj, anomalies = anomalies, res = res)

  return(detection)
}

