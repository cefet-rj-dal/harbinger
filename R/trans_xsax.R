#' @title XSAX transformation
#' @description
#' Extended SAX (XSAX) discretization using a larger alphanumeric alphabet
#' for finer symbolic resolution.
#'
#' @param alpha Integer. Alphabet size (2–36).
#' @return A `trans_xsax` transformer object.
#'
#' @examples
#' library(daltoolbox)
#' vector <- 1:52
#' model <- trans_xsax(alpha = 36)
#' model <- fit(model, vector)
#' xvector <- transform(model, vector)
#' print(xvector)
#'
#' @seealso trans_sax
#'
#' @importFrom daltoolbox dal_transform
#' @importFrom daltoolbox fit
#' @importFrom daltoolbox transform
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. 1st ed.
#'   Cham: Springer Nature Switzerland, 2025. doi:10.1007/978-3-031-75941-3
#' @export
trans_xsax <- function(alpha) {
  obj <- dal_transform()
  obj$alpha <- alpha
  class(obj) <- append("trans_xsax", class(obj))
  return(obj)
}

#'@importFrom stats quantile
binning_xsax <- function(v, a) {
  # Compute quantile-based bins and assign each value to a bin
  p <- base::seq(from = 0, to = 1, by = 1/a)
  q <- stats::quantile(v, p)
  qf <- base::matrix(c(q[1:(length(q)-1)],q[2:(length(q))]), ncol=2)
  vp <- base::cut(v, unique(q), FALSE, include.lowest=TRUE)
  m <- base::tapply(v, vp, mean)
  vm <- m[vp]
  mse <- base::mean((v - vm)^2, na.rm = TRUE)
  return (list(binning=m, bins_factor=vp, q=q, qf=qf, bins=vm, mse=mse))
}

#'@importFrom stringr str_length
convert_to_xsax <- function(num, nbase) {
  chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  if(nbase < 2 || nbase > stringr::str_length(chars))
    return("")
  newNumber <- ""
  r <- 0
  while(num >= nbase)
  {
    r <- num %% nbase
    newNumber <- base::sprintf("%s%s", substr(chars, r+1, r+1), newNumber)
    num <- as.integer(num / nbase)
  }
  newNumber = base::sprintf("%s%s", substr(chars, num+1, num+1), newNumber)
  return (newNumber)
}

convert_to_xsax_vec <- function(num, nbase) {
  n <- length(num)
  result <- rep("", n)
  for (i in 1:n) {
    result[i] <- convert_to_xsax(num[i], nbase)
  }
  return(result)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform trans_xsax
transform.trans_xsax <- function(obj, data, ...) {
  # Z-normalize series and quantile-bin into an extended alphabet
  vectorNorm <- (data - base::mean(data, na.rm = TRUE)) / stats::sd(data, na.rm = TRUE)
  mybin <- binning_xsax(vectorNorm, obj$alpha)
  i <- base::ceiling(log(obj$alpha, 36))
  mycode <- stringr::str_pad(convert_to_xsax_vec(0:(obj$alpha - 1), 36), i, pad = "0")
  saxvector <- mycode[mybin$bins_factor]

  return(saxvector)
}
