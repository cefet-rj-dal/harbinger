#'@title Adapted Hoeffding Drift Detection Method (HDDM) method
#'@description  is a drift detection method based on the Hoeffding’s inequality. HDDM_A uses the average as estimator.  <doi:10.1109/TKDE.2014.2345382>.
#'@param drift_confidence Confidence to the drift
#'@param warning_confidence Confidence to the warning
#'@param two_side_option Option to monitor error increments and decrements (two-sided) or only increments (one-sided)
#HDDM: Frías-Blanco I, del Campo-Ávila J, Ramos-Jimenez G, et al. Online and non-parametric drift detection methods based on Hoeffding’s bounds. IEEE Transactions on Knowledge and Data Engineering, 2014, 27(3): 810-823.
#HDDM implementation: Scikit-Multiflow, https://github.com/scikit-multiflow/scikit-multiflow/blob/a7e316d/src/skmultiflow/drift_detection/hddm_a.py#L6
#'@return `hcp_hddm` object
#'@examples
#'n <- 100  # Number of time points
#'example_type='multivariate'
# Multivariate Example
#'data <- as.data.frame(c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi), 10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2))
#'names(data) <- c('serie1')
#'data['serie2'] <- c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi), 10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2) + runif(length(data), 0, 1)
#'
#'event <- rep(FALSE, n)
#'
#'model <- fit(hcd_hddm(drift_confidence = 0.0000000001, warning_confidence=0.6), data)
#'detection <- detect(model, data)
#'
#'grf <- har_plot(model, data$serie1, detection)
#'grf <- grf + ylab("value")
#'grf <- grf

#'plot(grf)
#'@export
hcd_hddm <- function(drift_confidence=0.001, warning_confidence=0.005, two_side_option=TRUE) {
  obj <- harbinger()
  obj$n_min <- 0
  obj$c_min <- 0
  obj$total_n <- 0
  obj$total_c <- 0
  obj$n_max <- 0
  obj$c_max <- 0
  obj$n_estimation <- 0
  obj$c_estimation <- 0
  
  obj$drift_confidence <- drift_confidence
  obj$warning_confidence <- warning_confidence
  obj$two_side_option <- two_side_option
  
  obj$mean_incr <- function(c_min, n_min, total_c, total_n, confidence){
    if (n_min == total_n){
      return(FALSE)
    }
    m <- ((total_n - n_min) / n_min) * (1.0 / total_n)
    cota <- sqrt(m / (2 * log(2.0 / confidence)))
    return(((total_c / total_n) - (c_min / n_min)) >= cota)
  }
  
  obj$mean_decr <- function(c_max, n_max, total_c, total_n){
    if (n_max == total_n){
      return(FALSE)
    }
    m <- ((total_n - n_max) / n_max) * (1.0 / total_n)
    cota <- sqrt(m / (2 * log(2.0 / obj$drift_confidence)))
    return(((c_max / n_max) - (total_c / total_n)) >= cota)
  }
  
  obj$update_estimations <- function(obj){
    if(obj$total_n >= obj$n_estimation){
      obj$c_estimation <- 0
      obj$n_estimation <- 0
      
      obj$estimation <- obj$total_c / obj$total_n
      obj$delay <- obj$total_n
      return(obj)
    }
  }
  
  class(obj) <- append("hcd_hddm", class(obj))
  return(obj)
}

#'@importFrom stats ecdf
#'@importFrom stats complete.cases
#'@export
detect.hcd_hddm <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!is.data.frame(serie)) stop("serie is not a data frame", call. = FALSE)
  
  update <- function(obj, prediction){
    obj$total_n <- obj$total_n + 1
    obj$total_c <- obj$total_c + prediction
    if(obj$n_min == 0){
      obj$n_min = obj$total_n
      obj$c_min = obj$total_c
    }
    if(obj$n_max == 0){
      obj$n_max = obj$total_n
      obj$c_max = obj$total_c
      }
    
    cota <- sqrt(1.0 / (2 * obj$n_min) * log(1.0 / obj$drift_confidence))
    cota1 <- sqrt(1.0 / (2 * obj$total_n) * log(1.0 / obj$drift_confidence))
    
    if((obj$c_min / (obj$n_min + cota)) >= (obj$total_c / (obj$total_n + cota1))){
       obj$c_min <- obj$total_c
       obj$n_min <- obj$total_n
    }
    
    cota <- sqrt(1.0 / (2 * obj$n_max) * log(1.0 / obj$drift_confidence))
    if(obj$c_max / obj$n_max - cota <= obj$total_c / obj$total_n - cota1){
       obj$c_max = obj$total_c
      obj$n_max = obj$total_n
    }
    
    returned_value <- c()
    if(obj$mean_incr(obj$c_min, obj$n_min, obj$total_c, obj$total_n, obj$drift_confidence)){
      obj$.n_estimation = obj$total_n - obj$n_min
      obj$c_estimation = obj$total_c - obj$c_min
      obj$n_min = obj$n_max = obj$total_n = 0
      obj$c_min = obj$c_max = obj$total_c = 0
      obj$in_concept_change = TRUE
      obj$in_warning_zone = FALSE
      returned_value <- list(obj=obj, pred=TRUE)
    }else if(obj$mean_incr(obj$c_min, obj$n_min, obj$total_c, obj$total_n, obj$warning_confidence)){
      obj$in_concept_change = FALSE
      obj$in_warning_zone = TRUE
      returned_value <- list(obj=obj, pred=FALSE)
    }else{
      obj$in_concept_change = FALSE
      obj$in_warning_zone = TRUE
      returned_value <- list(obj=obj, pred=FALSE)
    }
    if(obj$two_side_option & obj$mean_decr(obj$c_max, obj$n_max, obj$total_c, obj$total_n)){
      obj$n_estimation = obj$total_n - obj$n_max
      obj$c_estimation = obj$total_c - obj$c_max
      obj$n_min = obj$n_max = obj$total_n = 0
      obj$c_min = obj$c_max = obj$total_c = 0
    }
    
    obj <- obj$update_estimations(obj)
    
    return(returned_value)
  }
  
  non_na <- base::which(stats::complete.cases(serie))
  data <- serie[non_na, , drop=FALSE]
  
  # Transform to percentile (0 to 1)
  data <- base::sapply(data, function(c) stats::ecdf(c)(c))
  data <- base::apply(data, 1, mean)
  
  # Perform change point detection using DDM
  ph_result <- rep(FALSE, length(data))
  output <- update(obj, data[1])
  for (i in 1:length(data)){
    output <- update(output$obj, data[i])
    ph_result[i] <- output$pred
  }
  
  inon_na <- rep(FALSE, length(non_na))
  n <- length(ph_result)
  if (n > 1)
    inon_na[ph_result[1:(n-1)]] <- TRUE
  
  i <- rep(NA, nrow(serie))
  i[non_na] <- inon_na
  detection <- data.frame(idx=1:length(i), event = i, type="")
  detection$type[i] <- "changepoint"
  
  return(detection)
}
