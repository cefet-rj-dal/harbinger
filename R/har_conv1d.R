#'@title Conv1D
#'@description Creates a time series prediction object that uses the Conv1D.
#' It wraps the pytorch library.
#'@param preprocess normalization
#'@param input_size input size for machine learning model
#'@param epochs maximum number of epochs
#'@return a `har_conv1d` object.
#'@examples
#'\dontrun{
#'library(daltoolbox)
#'data(sin_data)
#'ts <- ts_data(sin_data$y, 10)
#'ts_head(ts, 3)
#'
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'model <- har_conv1d(ts_norm_gminmax(), input_size=4, epochs = 10000L)
#'model <- fit(model, x=io_train$input, y=io_train$output)
#'
#'prediction <- predict(model, x=io_test$input[1,], steps_ahead=5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'}
#'@import daltoolbox
#'@import reticulate
#'@export
har_conv1d <- function(preprocess = NA, input_size = NA, epochs = 10000L) {
  obj <- ts_regsw(preprocess, input_size)
  obj$channels <- 1
  obj$epochs <- epochs
  class(obj) <- append("har_conv1d", class(obj))
  return(obj)
}

#'@export
do_fit.har_conv1d <- function(obj, x, y) {
  reticulate::source_python(system.file("python", "har_conv1d.py", package = "tspredit"))

  if (is.null(obj$model))
    obj$model <- create_torch_conv1d(obj$channels, obj$input_size)

  df_train <- as.data.frame(x)
  df_train$t0 <- as.vector(y)

  obj$model <- train_torch_conv1d(obj$model, df_train, obj$epochs, 0.001)

  return(obj)
}

#'@export
do_predict.har_conv1d <- function(obj, x) {
  reticulate::source_python(system.file("python", "har_conv1d.py", package = "tspredit"))

  X_values <- as.data.frame(x)
  X_values$t0 <- 0
  prediction <- predict_torch_conv1d(obj$model, X_values)
  prediction <- as.vector(prediction)
  return(prediction)
}
