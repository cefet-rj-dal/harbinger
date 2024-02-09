#library(hht)#CEEMD
#library(ggplot2)


hanr_emd_arima <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL

  class(obj) <- append("hanr_emd_arima", class(obj))
  return(obj)
}

fit.hanr_emd_arima <- function(obj, serie, noise = 0.1, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  serie <- stats::na.omit(serie)
  w=30
  # original era 0.001
  noise.amp = noise
  trials=5
  serie <- ts(serie)

  id <-  1:length(serie)
  obj$sw_size <-  length(serie)
  ceemd.result <- CEEMD(serie, id, noise, trials)

  obj$model <- ceemd.result

  return(obj)
}


detect.hanr_emd_arima <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)

  ## calculate roughness for each imf
  vec <- vector()
  for (n in 1:obj$model$nimf){
    vec[n] <- fc_roughness(obj$model[["imf"]][,n])
  }

  ## Maximum curvature
  res <- transform(fit_curvature_max(), vec)
  div <- res$x
  sum_high_freq <- obj$model[["imf"]][,1]

  for (k in 2:div){
    sum_high_freq <- sum_high_freq + obj$model[["imf"]][,k]}

  # identification of anomaly points EMD
  diff_high_freq <- c(NA, diff(sum_high_freq))
  median_high_freq <- median(abs(diff_high_freq), na.rm= TRUE)
  distance <- abs(diff_high_freq) -  median_high_freq
  outliers_emd <- which(abs(distance)>2.698*sd(distance, na.rm=TRUE))

  # Arima process
  ts <- ts_data(sum_high_freq, 0)
  io <- ts_projection(ts)
  model <- ts_arima()
  model <- fit(model, x=io$input, y=io$output)
  adjust <- predict(model, io$input)
  adjust <- as.vector(adjust)

  # Calculation of inverse probability
  delta <- abs(adjust - sum_high_freq)
  probability <-((1 - delta) / max(delta))

  outliers_arima <- which(abs(probability)<2.698*sd(probability, na.rm=TRUE))

  obj$anomalies[1:obj$sw_size] <- FALSE

  if (!is.null(outliers_arima) & length(outliers_arima) > 0) {
    obj$anomalies[outliers_arima] <- TRUE
  }

  detection <- obj$har_restore_refs(obj, anomalies = obj$anomalies)
  return(detection)

}

## Roughness Function
fc_roughness <- function(x){
  firstD = diff(x)
  normFirstD = (firstD - mean(firstD)) / sd(firstD)
  roughness = (diff(normFirstD) ** 2) / 4
  return(mean(roughness))
}
