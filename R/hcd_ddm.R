#'@title Adapted Drift Detection Method (DDM) method
#'@description DDM is a concept change detection method based on the PAC learning model premise, that the learner’s error rate will decrease as the number of analysed samples increase, as long as the data distribution is stationary. <doi:10.1007/978-3-540-28645-5_29>.
#'@param min_instances The minimum number of instances before detecting change
#'@param warning_level Necessary level for warning zone (2 standard deviation)
#'@param out_control_level Necessary level for a positive drift detection
#DDM: João Gama, Pedro Medas, Gladys Castillo, Pedro Pereira Rodrigues: Learning with Drift Detection. SBIA 2004: 286-295.
#DDM implementation: Scikit-Multiflow, https://github.com/scikit-multiflow/scikit-multiflow/blob/a7e316d/src/skmultiflow/drift_detection/ddm.py
#'@return `hcp_ddm` object
#'@examples
#'library(daltoolbox)
#'library(ggplot2)
#'set.seed(6)
#'
#'# Loading the example database
#'data(har_examples)
#'
#'#Using example 1
#'dataset <- har_examples$example1
#'cut_index <- 60
#'srange <- cut_index:row.names(dataset)[nrow(dataset)]
#'drift_size <- nrow(dataset[srange,])
#'dataset[srange, 'serie'] <- dataset[srange, 'serie'] + rnorm(drift_size, mean=0, sd=0.5)
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
#'model <- fit(hcd_ddm(min_instances=10, out_control_level = 2, warning_level=0), drift_evaluation)
#'detection_drift <- detect(model, drift_evaluation)
#'
#'grf <- har_plot(model, dataset$serie, detection_drift)
#'grf <- grf + ggplot2::ylab("value")
#'grf <- grf
#'
#'plot(grf)
#'@export
hcd_ddm <- function(min_instances=30, warning_level=2.0, out_control_level=3.0) {
  obj <- harbinger()
  obj$min_instances <- min_instances
  obj$warning_level <- warning_level
  obj$out_control_level <- out_control_level

  obj$sample_count <- 1
  obj$miss_prob <- 1.0
  obj$miss_std <- 0.0
  obj$miss_prob_sd_min <- Inf
  obj$miss_prob_min <- Inf
  obj$miss_sd_min <- Inf

  class(obj) <- append("hcd_ddm", class(obj))
  return(obj)
}

#'@importFrom stats ecdf
#'@importFrom stats complete.cases
#'@export
detect.hcd_ddm <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!is.data.frame(serie)) stop("serie is not a data frame", call. = FALSE)

  update <- function(obj, x){
    obj$miss_prob <- obj$miss_prob + (x - obj$miss_prob) / obj$sample_count
    obj$miss_std <- sqrt(obj$miss_prob * (1 - obj$miss_prob)) / obj$sample_count
    obj$sample_count <- obj$sample_count + 1

    obj$estimation <- obj$miss_prob
    obj$in_concept_change <- FALSE
    obj$in_warning_zone <- FALSE
    obj$delay <- 0

    if(obj$sample_count < obj$min_instances){
      return(list(obj=obj, pred=FALSE))
    }

    if((obj$miss_prob + obj$miss_std) <= obj$miss_prob_sd_min){
      obj$miss_prob_min <- obj$miss_prob
      obj$miss_sd_min <- obj$miss_std
      obj$miss_prob_sd_min <- obj$miss_prob + obj$miss_std
      obj$sum <- 0
      obj$sample_count <- 1
    }

    if((obj$miss_prob + obj$miss_std) > (obj$miss_prob_min + obj$out_control_level * obj$miss_sd_min)){
      obj$sample_count <- 1
      obj$miss_prob <- 1.0
      obj$miss_std <- 0.0
      obj$miss_prob_sd_min <- Inf
      obj$miss_prob_min <- Inf
      obj$miss_sd_min <- Inf
      return(list(obj=obj, pred=TRUE))
    }else if((obj$miss_prob + obj$miss_std) > (obj$miss_prob_min + obj$warning_level * obj$miss_sd_min)){
      return(list(obj=obj, pred=FALSE))
    }else{
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
