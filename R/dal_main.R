# DAL Library
# version 2.1

### basic transformation functions

#'@title dal_base object
#'@description
#'@details
#'
#'@return
#'@examples
#'@export
dal_base <- function() {
  obj <- list()
  obj$log <- FALSE
  obj$debug <- FALSE
  obj$reproduce <- FALSE
  attr(obj, "class") <- "dal_base"
  return(obj)
}

#'@title Generates a dal_transform object
#'@description
#'@details
#'
#'@return
#'@examples
#'@export
dal_transform <- function() {
  obj <- dal_base()
  class(obj) <- append("dal_transform", class(obj))
  return(obj)
}

#fit
#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
fit <- function(obj, ...) {
  UseMethod("fit")
}

#'@export
fit.default <- function(obj, ...) {
  return(obj)
}

#transform
#'@title Transform
#'@description
#'@details
#'
#'@param obj object: .
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
transform <- function(obj, ...) {
  UseMethod("transform")
}

#'@export
transform.default <- function(obj, ...) {
  return(NULL)
}

#inverse_transform
#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
inverse_transform <- function(obj, ...) {
  UseMethod("inverse_transform")
}

#'@export
inverse_transform.default <- function(obj, ...) {
  return(NULL)
}

#optimize
#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
optimize <- function(obj, ...) {
  UseMethod("optimize")
}

#'@export
optimize.default <- function(obj) {
  return(obj)
}

#head
#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
head <- function(obj, ...) {
  UseMethod("head")
}

#'@export
head.default <- function(obj, ...) {
  utils::head(obj, ...)
}

#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@param ... optional arguments./ further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
describe <- function(obj, ...) {
  UseMethod("describe")
}

#'@export
describe.default <- function(obj) {
  if (is.null(obj))
    return("")
  else
    return(as.character(class(obj)[1]))
}

### basic data structures for sliding windows

# general functions
#'@export
adjust_matrix <- function(data) {
  if(!is.matrix(data)) {
    return(as.matrix(data))
  }
  else
    return(data)
}

#'@export
adjust_data.frame <- function(data) {
  if(!is.data.frame(data)) {
    return(as.data.frame(data))
  }
  else
    return(data)
}


### Basic log functions

#start_log
#'@title
#'@description
#'@details
#'
#'@param obj object: .
#'@return
#'@examples
#'@export
start_log <- function(obj) {
  UseMethod("start_log")
}

#'@export
start_log.default <- function(obj) {
  obj$log_time <- Sys.time()
  return(obj)
}

#register_log
#'@title Register log details
#'@description
#'@details
#'
#'@param obj object: .
#'@param msg string: a message to the log.
#'@param ref .
#'@return
#'@examples
#'@export
register_log <- function(obj, msg, ref) {
  UseMethod("register_log")
}

#'@export
register_log.default <- function(obj, msg = "") {
  obj$log_time <- as.numeric(difftime(Sys.time(), obj$log_time, units = "min"))
  if (msg == "")
    msg <- describe(obj)
  obj$log_msg <- sprintf("%s,%.3f", msg, obj$log_time)
  message(obj$log_msg)
  return(obj)
}
