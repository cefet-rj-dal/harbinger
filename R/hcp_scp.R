#'@title Seminal change point
#'@description Change-point detection is related to event/trend change detection. Seminal change point detects change points based on deviations of linear regression models adjusted with and without a central observation in each sliding window <10.1145/312129.312190>.
#'@param sw_size Sliding window size
#'@return `hcp_scp` object
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
#'model <- hcp_scp()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hcp_scp <- function(sw_size = 30) {
  obj <- harbinger()
  obj$sw_size <- sw_size

  class(obj) <- append("hcp_scp", class(obj))
  return(obj)
}

#'@importFrom stats lm
#'@importFrom stats na.omit
#'@export
detect.hcp_scp <- function(obj, serie, ...) {
  analyze_window <- function(data, offset) {
    n <- length(data)
    y <- data.frame(t = 1:n, y = data)

    mdl <- stats::lm(y~t, y)
    err <- mean(obj$har_residuals(mdl$residuals))

    y_a <- y[1:(offset-1),]
    mdl_a <- stats::lm(y~t, y_a)
    y_d <- y[(offset+1):n,]
    mdl_d <- stats::lm(y~t, y_d)

    err_ad <- mean(obj$har_residuals(c(mdl_a$residuals,mdl_d$residuals)))

    #return 1-error on whole window; 2-error on window halves; 3-error difference
    return(data.frame(mdl=err, mdl_ad=err_ad, mdl_dif=err-err_ad))
  }

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  sx <- ts_data(obj$serie, obj$sw_size)
  obj$offset <- round(obj$sw_size/2)

  #===== Analyzing all data windows ======
  errors <- do.call(rbind,apply(sx, 1, analyze_window, obj$offset))

  res <- errors$mdl_dif

  change_point <- obj$har_outliers_idx(res)
  change_point <- obj$har_outliers_group(change_point, length(res), res)

  change_point <- c(rep(FALSE, obj$offset-1), change_point, rep(FALSE, obj$sw_size-obj$offset))

  detection <- obj$har_restore_refs(obj, change_point = change_point)

  return(detection)
}
