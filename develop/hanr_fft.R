library(changepoint)

hanr_fft <- function() {
  obj <- harbinger()
  obj$sw_size <- NULL
  
  class(obj) <- append("hanr_fft", class(obj))
  return(obj)
}

fit.hanr_fft <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)
  
  serie <- stats::na.omit(serie)
  
  fft_sinal <- fft(serie)
  espectro <- Mod(fft_sinal)^2
  resultado_espectro <- espectro[1:(length(serie)/2 + 1)]
  
  cusum_valores <- cumsum(espectro_result)
  
  resultado_cpt <- cpt.mean(cusum_valores, method="BinSeg")
  i <- length(cpts(resultado_cpt))
  ponto_mudanca <- cpts(resultado_cpt)[i]
  
  obj$model <- ponto_mudanca
  
  if (is.null(obj$sw_size))
    obj$sw_size <- max(obj$p, obj$d+1, obj$q)
  
  return(obj)
}

detect.hanr_fft <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)
  
  serie <- stats::na.omit(serie)
  
  fft_sinal <- fft(serie)
  
  fft_sinal[1:ponto_mudanca] <- 0
  fft_sinal[(n - ponto_mudanca):n] <- 0
  
  sinal_filtrado_alta <- Re(fft(fft_sinal, inverse = TRUE) / length(fft_sinal))
  
  tamanho_sinal <- length(sinal_filtrado_alta)
  dez_por_cento <- round(tamanho_sinal * 0.10)
  
  sinal_central <- sinal_filtrado_alta[(dez_por_cento + 1):(tamanho_sinal - dez_por_cento)]
  
  limiar_alta <- mean(abs(sinal_central)) + 2.698 * sd(abs(sinal_central))
  
  anomalias_alta <- which(abs(sinal_filtrado_alta) > limiar_alta) 
  
  anomalies[1:obj$sw_size] <- FALSE
  
  if(is.null(anomalias_alta) & length(anomalias_alta) > 0) (
    obj$anomalies[anomalias_alta] <- TRUE
  )
  
  detection <- obj$har_restore_refs(obj, anomalies = obj$anomalies)
  
  return(detection)
}