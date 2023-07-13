#'@title Seminal change point
#'@description Seminal change point
#'@param sw Sliding window size
#'@return hcp_scp object
#'@examples detector <- harbinger()
#'@export
hcp_scp <- function(sw = 30) {
  obj <- harbinger()
  obj$sw <- sw

  class(obj) <- append("changepoint", class(obj))
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

  sx <- ts_data(stats::na.omit(serie), obj$sw)
  obj$offset <- round(obj$sw/2)

  #===== Analyzing all data windows ======
  errors <- do.call(rbind,apply(sx, 1, analyze_window, obj$offset))

  #Returns index of windows with outlier error differences
  index.cp <- obj$har_outliers(errors$mdl_dif)
  index.cp <- c(rep(FALSE, obj$offset-1), index.cp, rep(FALSE, obj$sw-obj$offset))

  inon_na <- index.cp

  i <- rep(NA, length(serie))
  i[non_na] <- inon_na

  detection <- data.frame(idx=1:length(serie), event = i, type="")
  detection$type[i] <- "changepoint"

  return(detection)
}
