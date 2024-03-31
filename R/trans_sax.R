#'@title SAX
#'@description SAX
#'@param alpha alphabet
#'@return obj
#'@examples
#'library(daltoolbox)
#'vector <- 1:52
#'model <- trans_sax(alpha = 26)
#'model <- fit(model, vector)
#'xvector <- transform(model, vector)
#'print(xvector)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
trans_sax <- function(alpha) {
  obj <- dal_transform()
  obj$alpha <- alpha
  class(obj) <- append("trans_sax", class(obj))
  return(obj)
}

#'@importFrom stats quantile
binning_sax <- function(v, a) {
  p <- base::seq(from = 0, to = 1, by = 1 / a)
  q <- stats::quantile(v, p)
  qf <- base::matrix(c(q[1:(length(q) - 1)], q[2:(length(q))]), ncol = 2)
  vp <- base::cut(v, unique(q), FALSE, include.lowest = TRUE)
  m <- base::tapply(v, vp, mean)
  vm <- m[vp]
  mse <- base::mean((v - vm) ^ 2, na.rm = TRUE)
  return (list(binning = m, bins_factor = vp, q = q, qf = qf, bins = vm, mse = mse))
}

#'@importFrom stringr str_length
convert_to_sax <- function(num, nbase) {
  chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  if (nbase < 2 || nbase > stringr::str_length(chars))
    return("")
  newNumber <- ""
  r <- 0
  while (num >= nbase)
  {
    r <- num %% nbase
    newNumber <- base::sprintf("%s%s", substr(chars, r + 1, r + 1), newNumber)
    num <- as.integer(num / nbase)
  }
  newNumber = base::sprintf("%s%s", substr(chars, num + 1, num + 1), newNumber)
  return (newNumber)
}

convert_to_sax_vec <- function(num, nbase) {
  n <- length(num)
  result <- rep("", n)
  for (i in 1:n) {
    result[i] <- convert_to_sax(num[i], nbase)
  }
  return(result)
}

#'@importFrom daltoolbox transform
#'@export
transform.trans_sax <- function(obj, data, ...) {
  vectorNorm <- (data - base::mean(data, na.rm = TRUE)) / stats::sd(data, na.rm = TRUE)
  mybin <- binning_sax(vectorNorm, obj$alpha)
  i <- base::ceiling(log(obj$alpha, 26))
  mycode <- stringr::str_pad(convert_to_sax_vec(0:(obj$alpha - 1), 26), i, pad = "0")
  saxvector <- mycode[mybin$bins_factor]

  return(saxvector)
}
