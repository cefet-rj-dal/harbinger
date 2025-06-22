#'@title Seminal change point
#'@description Change-point detection is related to event/trend change detection. Seminal change point detects change points based on deviations of linear regression models adjusted with and without a central observation in each sliding window <10.1145/312129.312190>.
#'@param sw_size Sliding window size
#'@return `hcp_scp` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_changepoints)
#'
#'#Using simple example
#'dataset <- examples_changepoints$simple
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

  hutils <- harutils()
  obj$har_outliers <- hutils$har_outliers_boxplot
  obj$har_outliers_check <- hutils$har_outliers_checks_highgroup

  class(obj) <- append("hcp_scp", class(obj))
  return(obj)
}

#'@importFrom stats lm
#'@importFrom stats na.omit
#'@exportS3Method detect hcp_scp
detect.hcp_scp <- function(obj, serie, ...) {
  analyze_window <- function(data, offset) {
    n <- length(data)
    y <- data.frame(t = 1:n, y = data)

    mdl <- stats::lm(y~t, y)
    res <- obj$har_distance(mdl$residuals)
    err <- mean(res)

    y_a <- y[1:(offset-1),]
    mdl_a <- stats::lm(y~t, y_a)
    y_d <- y[(offset+1):n,]
    mdl_d <- stats::lm(y~t, y_d)

    res_ad <- obj$har_distance(c(mdl_a$residuals,mdl_d$residuals))
    err_ad <- mean(res_ad)

    #return 1-error on whole window; 2-error on window halves; 3-error difference
    return(data.frame(mdl=err, mdl_ad=err_ad, mdl_dif=err-err_ad))
  }

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  sx <- tspredit::ts_data(obj$serie, obj$sw_size)
  obj$offset <- round(obj$sw_size/2)

  #===== Analyzing all data windows ======
  errors <- do.call(rbind,apply(sx, 1, analyze_window, obj$offset))

  res <- errors$mdl_dif

  change_point <- obj$har_outliers(res)
  change_point <- obj$har_outliers_check(change_point, res)

  threshold <- attr(change_point, "threshold")
  res <- c(rep(0, obj$offset), res, rep(0, obj$sw_size - obj$offset - 1))
  change_point <- c(rep(FALSE, obj$offset), change_point, rep(FALSE, obj$sw_size - obj$offset - 1))
  attr(change_point, "threshold") <- threshold

  detection <- obj$har_restore_refs(obj, change_point = change_point, res = res)

  return(detection)
}
