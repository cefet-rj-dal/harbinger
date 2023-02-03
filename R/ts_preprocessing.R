# DAL Library
# version 2.1

# depends dal_transform.R
# depends dal_outliers.R
# depends ts_data.R

# ts_normalize

#'@title
#'@description
#'@details
#'
#'@param remove_outliers logical: if TRUE outliers will be removed.
#'@return
#'@examples
#'@export
ts_normalize <- function(remove_outliers = TRUE) {
  obj <- dal_transform()
  obj$remove_outliers <- remove_outliers
  class(obj) <- append("ts_normalize", class(obj))
  return(obj)
}

# ts_gminmax
#'@title
#'@description
#'@details
#'
#'@param remove_outliers logical: if TRUE outliers will be removed.
#'@return
#'@examples
#'@export
ts_gminmax <- function(remove_outliers = TRUE) {
  obj <- ts_normalize(remove_outliers)
  class(obj) <- append("ts_gminmax", class(obj))
  return(obj)
}

#'@export
fit.ts_gminmax <- function(obj, data) {
  if (obj$remove_outliers) {
    out <- outliers()
    out <- fit(out, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)

  return(obj)
}

#'@export
transform.ts_gminmax <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    x <- (x-obj$gmin)/(obj$gmax-obj$gmin)
    return(x)
  }
  else {
    data <- (data-obj$gmin)/(obj$gmax-obj$gmin)
    return(data)
  }
}

#'@export
inverse_transform.ts_gminmax <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    return (data)
  }
}

#ts_diff
#'@title
#'@description
#'@details
#'
#'@param remove_outliers logical: if TRUE outliers will be removed.
#'@return
#'@examples
#'@export
ts_diff <- function(remove_outliers = TRUE) {
  obj <- ts_normalize(remove_outliers)
  class(obj) <- append("ts_diff", class(obj))
  return(obj)
}

#'@export
fit.ts_diff <- function(obj, data) {
  data <- data[,2:ncol(data)]-data[,1:(ncol(data)-1)]
  obj <- fit.ts_gminmax(obj, data)
  return(obj)
}

#'@export
transform.ts_diff <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    ref <- attr(data, "ref")
    sw <- attr(data, "sw")
    x <- x-ref
    x <- (x-obj$gmin)/(obj$gmax-obj$gmin)
    return(x)
  }
  else {
    ref <- as.vector(data[,ncol(data)])
    cnames <- colnames(data)
    for (i in (ncol(data)-1):1)
      data[,i+1] <- data[, i+1] - data[,i]
    data <- data[,2:ncol(data)]
    data <- (data-obj$gmin)/(obj$gmax-obj$gmin)
    attr(data, "ref") <- ref
    attr(data, "sw") <- ncol(data)
    attr(data, "cnames") <- cnames
    return(data)
  }
}

#'@export
inverse_transform.ts_diff <- function(obj, data, x=NULL) {
  cnames <- attr(data, "cnames")
  ref <- attr(data, "ref")
  sw <- attr(data, "sw")
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    x <- x + ref
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    data <- cbind(data, ref)
    for (i in (ncol(data)-1):1)
      data[,i] <- data[, i+1] - data[,i]
    colnames(data) <- cnames
    attr(data, "ref") <- ref
    attr(data, "sw") <- ncol(data)
    attr(data, "cnames") <- cnames
    return(data)
  }
}

#ts_swminmax
#'@title
#'@description
#'@details
#'
#'@param remove_outliers logical: if TRUE outliers will be removed.
#'@return
#'@examples
#'@export
ts_swminmax <- function(remove_outliers = TRUE) {
  obj <- ts_normalize(remove_outliers)
  class(obj) <- append("ts_swminmax", class(obj))
  return(obj)
}

#'@export
fit.ts_swminmax <- function(obj, data) {
  if (obj$remove_outliers) {
    out <- outliers()
    out <- fit(out, data)
    data <- transform(out, data)
  }
  return(obj)
}

#'@export
transform.ts_swminmax <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    i_min <- attr(data, "i_min")
    i_max <- attr(data, "i_max")
    x <- (x-i_min)/(i_max-i_min)
    return(x)
  }
  else {
    i_min <- apply(data, 1, min)
    i_max <- apply(data, 1, max)
    data <- (data-i_min)/(i_max-i_min)
    attr(data, "i_min") <- i_min
    attr(data, "i_max") <- i_max
    return(data)
  }
}

#'@export
inverse_transform.ts_swminmax <- function(obj, data, x=NULL) {
  i_min <- attr(data, "i_min")
  i_max <- attr(data, "i_max")
  if (!is.null(x)) {
    x <- x * (i_max - i_min) + i_min
    return(x)
  }
  else {
    data <- data * (i_max - i_min) + i_min
    attr(data, "i_min") <- i_min
    attr(data, "i_max") <- i_max
    return(data)
  }
}

#ts_an
#'@title
#'@description
#'@details
#'
#'@param remove_outliers logical: if TRUE outliers will be removed.
#'@param nw integer: .
#'@return
#'@examples
#'@export
ts_an <- function(remove_outliers = TRUE, nw = 0) {
  obj <- ts_normalize(remove_outliers)
  obj$an_mean <- mean
  obj$nw <- nw
  class(obj) <- append("ts_an", class(obj))
  return(obj)
}

#'@export
ma.ts_an <- function(obj, data, func) {
  if (obj$nw != 0) {
    cols <- ncol(data) - ((obj$nw-1):0)
    data <- data[,cols]

  }
  an <- apply(data, 1, func, na.rm=TRUE)
}

#'@export
fit.ts_an <- function(obj, data) {
  input <- data[,1:(ncol(data)-1)]
  an <- ma.ts_an(obj, input, obj$an_mean)
  data <- data - an #

  if (obj$remove_outliers) {
    out <- outliers()
    out <- fit(out, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)

  return(obj)
}

#'@export
transform.ts_an <- function(obj, data, x=NULL) {
  if (!is.null(x)) {
    an <- attr(data, "an")
    x <- x - an #
    x <- (x - obj$gmin) / (obj$gmax-obj$gmin)
    return(x)
  }
  else {
    an <- ma.ts_an(obj, data, obj$an_mean)
    data <- data - an #
    data <- (data - obj$gmin) / (obj$gmax-obj$gmin)
    attr(data, "an") <- an
    return (data)
  }
}

#'@export
inverse_transform.ts_an <- function(obj, data, x=NULL) {
  an <- attr(data, "an")
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    x <- x + an #
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    data <- data + an #
    attr(data, "an") <- an
    return (data)
  }
}

#'@title
#'@description
#'@details
#'
#'@param remove_outliers
#'@param nw
#'@return
#'@examples
#'@export
ts_ean <- function(remove_outliers = TRUE, nw = 0) {
  emean <- function(data, na.rm = FALSE) {
    n <- length(data)

    y <- rep(0, n)
    alfa <- 1 - 2.0 / (n + 1);
    for (i in 0:(n-1)) {
      y[n-i] <- alfa^i
    }

    m <- sum(y * data, na.rm = na.rm)/sum(y, na.rm = na.rm)
    return(m)
  }
  obj <- ts_an(remove_outliers, nw = nw)
  obj$an_mean <- emean
  class(obj) <- append("ts_ean", class(obj))
  return(obj)
}

