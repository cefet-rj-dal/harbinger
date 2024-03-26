#'@title Adapted Early Drift Detection Method (EDDM) method
#'@description EDDM (Early Drift Detection Method) aims to improve the detection rate of gradual concept drift in DDM, while keeping a good performance against abrupt concept drift. <doi:2747577a61c70bc3874380130615e15aff76339e>
#'@param min_instances The minimum number of instances before detecting change
#'@param min_num_errors The minimum number of errors before detecting change
#'@param warning_level Necessary level for warning zone
#'@param out_control_level Necessary level for a positive drift detection
#EDDM: Early Drift Detection Method. Manuel Baena-Garcia, Jose Del Campo-Avila, Raúl Fidalgo, Albert Bifet, Ricard Gavalda, Rafael Morales-Bueno. In Fourth International Workshop on Knowledge Discovery from Data Streams, 2006.
#EDDM implementation: Scikit-Multiflow, https://github.com/scikit-multiflow/scikit-multiflow/blob/a7e316d/src/skmultiflow/drift_detection/eddm.py
#'@return `hcp_eddm` object
#'@examples
#'library("daltoolbox")
#'set.seed(6)
#'
#'# Loading the example database
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
#'cut_index <- 60
#'drift_size <- nrow(dataset[cut_index:row.names(dataset)[nrow(dataset)],])
#'dataset[cut_index:row.names(dataset)[nrow(dataset)], 'serie'] <- dataset[cut_index:row.names(dataset)[nrow(dataset)], 'serie'] + rnorm(drift_size, mean=0, sd=0.5)
#'head(dataset)
#'
#'plot(x=row.names(dataset), y=dataset$serie, type='l')
#'
#'# Setting up time series regression model
#'model <- hanct_kmeans()
#'
#'# Fitting the model
#'model <- fit(model, dataset$serie)
#'
#'# Making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# Filtering detected events
#'print(detection[(detection$event),])
#'
#'# Drift test
#'
#'drift_evaluation <- data.frame(!(detection$event == dataset$event)) * 1
#'model <- fit(hcd_eddm(min_instances=10, out_control_level = 0.9, warning_level = 0.95), drift_evaluation)
#'detection_drift <- detect(model, drift_evaluation)
#'
#'grf <- har_plot(model, dataset$serie, detection_drift)
#'grf <- grf + ylab("value")
#'grf <- grf
#'
#'plot(grf)
#'@export
hcd_eddm <- function(min_instances=30, min_num_errors=1, warning_level=0.95, out_control_level=0.9) {
  
  obj <- harbinger()
  obj$min_instances <- min_instances
  obj$m_min_num_errors <- min_num_errors
  obj$warning_level <- warning_level
  obj$out_control_level <- out_control_level
  
  obj$m_num_errors <- NULL
  obj$m_last_level <- NULL
  
  obj$m_n <- 1
  obj$m_num_errors <- 0
  obj$m_d <- 0
  obj$m_lastd <- 0
  obj$m_mean <- 0.0
  obj$m_std_temp <- 0.0
  obj$m_m2s_max <- 0.0
  obj$estimation <- 0.0
  obj$concept_change <- FALSE
  
  class(obj) <- append("hcd_eddm", class(obj))
  return(obj)
}

#'@importFrom stats ecdf
#'@importFrom stats complete.cases
#'@export
detect.hcd_eddm <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!is.data.frame(serie)) stop("serie is not a data frame", call. = FALSE)
  
  update <- function(obj, x){
    obj$m_n <- obj$m_n + 1
    
    if(x == 1){
      obj$delay <- 0
      obj$m_num_errors <- obj$m_num_errors + 1
      obj$m_lastd <- obj$m_d
      obj$m_d <- obj$m_n - 1
      distance <- obj$m_d - obj$m_lastd
      old_mean <- obj$m_mean
      obj$m_mean <- obj$m_mean + (distance - obj$m_mean) / obj$m_num_errors
      obj$estimation <- obj$m_mean
      obj$m_std_temp <- obj$m_std_temp + (distance - obj$m_mean) * (distance - old_mean)
      std <- sqrt(obj$m_std_temp / obj$m_num_errors)
      m2s <- obj$m_mean + 2 * std
      
      if(obj$m_n < obj$min_instances){
        return(list(obj=obj, pred=FALSE))
      }
      
      if(m2s > obj$m_m2s_max){
        obj$m_m2s_max <- m2s
        return(list(obj=obj, pred=FALSE))
      }
      else{
        p <- m2s / obj$m_m2s_max
        
        if((obj$m_num_errors > obj$m_min_num_errors) & (p < obj$out_control_level)){
          obj$m_n <- 1
          obj$m_num_errors <- 0
          obj$m_d <- 0
          obj$m_lastd <- 0
          obj$m_mean <- 0.0
          obj$m_std_temp <- 0.0
          obj$m_m2s_max <- 0.0
          obj$estimation <- 0.0
          obj$concept_change <- FALSE
          
          return(list(obj=obj, pred=TRUE))
        }
      else if((obj$m_num_errors > obj$m_min_num_errors) & (p < obj$warning_level)){
        return(list(obj=obj, pred=FALSE))
      }
      else{
        return(list(obj=obj, pred=FALSE))
      }
     }
    }
    else{
      return(list(obj=obj, pred=FALSE))
    }
   }
  
  non_na <- base::which(stats::complete.cases(serie))
  data <- serie[non_na, ]
  
  # Transform to percentile (0 to 1) if data has more than one column
  #data <- base::sapply(data, function(c) stats::ecdf(c)(c))
  #data <- base::apply(data, 1, mean)
  
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
