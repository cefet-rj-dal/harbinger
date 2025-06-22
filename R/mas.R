#' Moving average smoothing
#'
#' The \code{mas()} function returns a simple moving average smoother of the
#' provided time series.
#'
#' The moving average smoother transformation is given by \deqn{(1/k) * (
#' x[t] + x[t+1] + ... + x[t+k-1] )} where \code{k=order}, \code{t} assume
#' values in the range \code{1:(n-k+1)}, and \code{n=length(x)}. See also the
#' \code{\link[forecast]{ma}} of the \code{forecast} package.
#'
#' @param x A numeric vector or univariate time series.
#' @param order Order of moving average smoother.
#' @return Numerical time series of length \code{length(x)-order+1} containing
#' the simple moving average smoothed values.
#' @references R.H. Shumway and D.S. Stoffer, 2010, Time Series Analysis and
#' Its Applications: With R Examples. 3rd ed. 2011 edition ed. New York,
#' Springer.
#' @keywords moving average smoother daltoolbox::transform time series
#' @examples
#'#loading the example database
#'data(examples_changepoints)
#'
#'#Using simple example
#'dataset <- examples_changepoints$simple
#'head(dataset)
#'
#'# setting up change point method
#'ma <- mas(dataset$serie, 5)
#' @export mas
mas <- function(x, order){
  n <- length(x)
  xt <- NULL
  for(t in 1:(n-order+1)){
    xt <- c(xt, sum(x[t:(t+order-1)])/order)
  }

  xt <- stats::ts(xt)
  attr(xt,"order") <- order
  attr(xt,"xi") <- utils::head(x,order-1)
  attr(xt,"xf") <- utils::tail(x,order-1)

  return(xt)
}

