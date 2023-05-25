# DAL Library
# version 2.1

### basic transformation functions

#'@title dal_base object
#'@description Creates a base object that will be used by other library functions
#'@details It creates an empty object, adds some boolean properties (log, debug and reproduce) to it, and then sets the object's class to "dal_base"
#'
#'@return An empty object
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

### basic transformation functions

#'@title DAL Transform
#'@description A transformation function can be applied to a time series dataset
#' to alter its properties.
#'@details
#'
#'@return a dal_transform object
#'@examples
#'@export
dal_transform <- function() {
  obj <- dal_base()
  class(obj) <- append("dal_transform", class(obj))
  return(obj)
}

#fit
#'@title Fit
#'@description Models a time series dataset by estimating the underlying trend
#' and seasonality components. Used to make predictions and forecast future
#' values of the time series based on the historical data.
#'@details
#'
#'@param obj object: .
#'@param ... further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
fit <- function(obj, ...) {
  UseMethod("fit")
}

#'@title dal_base object
#'@description Receives the obj object as a parameter, ...
#'@details
#'
#'@return The input object "obj"
#'@examples
#'@export
fit.default <- function(obj, ...) {
  return(obj)
}

#transform
#'@title Transform
#'@description Defines the kind of transformation to be set over a time series.
#'@details
#'
#'@param obj object: .
#'@param ... further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
transform <- function(obj, ...) {
  UseMethod("transform")
}

#'@title dal_base object
#'@description A default function that defines the default behavior of the transform function for objects of class dal_transform
#'@details This function can be overridden by other custom transform methods for dal_transform objects that require different behavior
#'
#'@param obj, ...
#'
#'@return It simply returns NULL, which indicates that no transforms are applied
#'@examples
#'@export
transform.default <- function(obj, ...) {
  return(NULL)
}

#inverse_transform
#'@title Call the specific method of the object's class
#'@description It takes as parameter the obj object, ...
#'@details The function serves as a dispatcher to select the correct implementation of the inverse transformation depending on the object class
#'
#'@param obj object: .
#'@param ... further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
inverse_transform <- function(obj, ...) {
  UseMethod("inverse_transform")
}


#'@title dal_base object
#'@description It receives as parameter the object obj, ...
#'@details It is used when no specific method is defined for a specific dal_transform object and the generic function inverse_transform() is called
#'
#'@param obj, ...
#'@return Simply returns NULL
#'@examples
#'@export
inverse_transform.default <- function(obj, ...) {
  return(NULL)
}

#optimize
#'@title Allow different types of objects to be optimized using different optimization algorithms
#'@description It uses the "UseMethod" method to call a specific optimization function for the object type that is passed to "obj"
#'@details This function is a generic wrapper for calling specific optimization functions for a given type of object in R.
#'
#'@param obj object: .
#'@param ... further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
optimize <- function(obj, ...) {
  UseMethod("optimize")
}

#'@title dal_base object
#'@description It receives as parameter the obj object
#'@details Generic method that calls a specific implementation to optimize an object, depending on its class. When there is no specific implementation defined for the object's class, the generic method optimize.default is called
#'
#'@param obj
#'@return Simply returns the object
#'@examples
#'@export
optimize.default <- function(obj) {
  return(obj)
}

#'@title Defines the generic method
#'@description It takes as parameter the object obj, ...
#'@details It instructs R to use the specific method description according to the class of the object given as an argument
#'
#'@param obj object: .
#'@param ... further arguments passed to or from other methods.
#'@return
#'@examples
#'@export
describe <- function(obj, ...) {
  UseMethod("describe")
}

#'@title dal_base object
#'@description It takes as parameter the object obj. It checks if the given object is NULL and returns an empty string in that case, otherwise it returns the object's class name as a string
#'@details This function provides a basic description of the given object
#'
#'@param obj
#'@return Class of the object passed as an argument in character format (string), if it is not null. If the object is null, the function returns an empty string
#'@examples
#'@export
describe.default <- function(obj) {
  if (is.null(obj))
    return("")
  else
    return(as.character(class(obj)[1]))
}

### basic data structures for sliding windows

# general functions
#'@title dal_base object
#'@description  It takes a data object as an argument
#'@details Useful for ensuring that an input object is treated as an array even if it is initially of another type
#'
#'@param data
#'@return An array corresponding to the object passed as a parameter, if it is not an array. If the object is already an array, the function simply returns it
#'@examples
#'@export
adjust_matrix <- function(data) {
  if(!is.matrix(data)) {
    return(as.matrix(data))
  }
  else
    return(data)
}

#'@title dal_base object
#'@description It takes as parameter an obj object
#'@details Essa verificação é útil quando uma função espera um data frame como entrada, mas o usuário fornece um objeto que não é um data frame
#'
#'@param data
#'@return The date argument
#'@examples
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
#'@title Start logging on an obj object
#'@description It takes as parameter an obj object
#'@details As it makes use of UseMethod, it is expected that there are other functions that define specific behaviors for different classes of objects
#'
#'@param obj object: .
#'@return
#'@examples
#'@export
start_log <- function(obj) {
  UseMethod("start_log")
}

#'@title dal_base object
#'@description It takes as parameter the obj object
#'@details This function is a method to start logging on an object. The default method assigns the current time to the object and returns it
#'
#'@param obj object: .
#'@return The object with a new attribute "log_time",
#'@examples
#'@export
start_log.default <- function(obj) {
  obj$log_time <- Sys.time()
  return(obj)
}

#register_log
#'@title Register log details
#'@description It takes as parameters the variables obj, msg and ref. It serves to direct the appropriate method call, depending on the type of object passed as the obj argument.
#'@details This function is just a wrapper for the register_log method that must be implemented by other functions that use this programming pattern
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

#'@title dal_base object
#'
#'@description It takes as parameters the obj object and the variable msg. This function logs a log message to an object and returns the updated object itself
#'
#'@details If the message is not provided, the function uses the describe function to get a description of the object's class as a log message. The function then calculates the time since the last time logging was started using the difftime function and stores the time in obj$log_time
#'
#'@param obj object: .
#'@param msg
#'@return The obj object updated with log record information
#'@examples
#'@export
register_log.default <- function(obj, msg = "") {
  obj$log_time <- as.numeric(difftime(Sys.time(), obj$log_time, units = "min"))
  if (msg == "")
    msg <- describe(obj)
  obj$log_msg <- sprintf("%s,%.3f", msg, obj$log_time)
  message(obj$log_msg)
  return(obj)
}
