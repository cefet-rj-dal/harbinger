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
#'# setting up time series regression model
#'model <- hcp_scp()
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection |> dplyr::filter(event==TRUE))
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
    err <- mean(mdl$residuals^2)

    y_a <- y[1:(offset-1),]
    mdl_a <- stats::lm(y~t, y_a)
    y_d <- y[(offset+1):n,]
    mdl_d <- stats::lm(y~t, y_d)

    err_ad <- mean(obj$har_residuals(c(mdl_a$residuals,mdl_d$residuals)))

    #return 1-error on whole window; 2-error on window halves; 3-error difference
    return(data.frame(mdl=err, mdl_ad=err_ad, mdl_dif=err-err_ad))
  }

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  non_na <- which(!is.na(serie))

  sx <- ts_data(stats::na.omit(serie), obj$sw_size)
  obj$offset <- round(obj$sw_size/2)

  #===== Analyzing all data windows ======
  errors <- do.call(rbind,apply(sx, 1, analyze_window, obj$offset))

  #Returns index of windows with outlier error differences
  index.cp <- obj$har_outliers(errors$mdl_dif)
  index.cp <- c(rep(FALSE, obj$offset-1), index.cp, rep(FALSE, obj$sw_size-obj$offset))

  inon_na <- index.cp

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "changepoint"

  return(detection)
}
