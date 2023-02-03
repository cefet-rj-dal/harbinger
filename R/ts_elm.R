# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_elm
# loadlibrary("elmNNRcpp")

### ts_augment
#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param nhid
#'@param actfun
#'@return
#'@examples
#'@export
ts_elm <- function(preprocess=NA, input_size=NA, nhid=NA, actfun='purelin') {
  obj <- tsreg_sw(preprocess, input_size)
  if (is.na(nhid))
    nhid <- input_size/3
  #nhid=c(3:8)
  obj$nhid <- nhid
  #actfun = c('sig', 'radbas', 'tribas', 'relu', 'purelin')
  obj$actfun <- as.character(actfun)

  class(obj) <- append("ts_elm", class(obj))
  return(obj)
}

#'@export
set_params.ts_elm <- function(obj, params) {
  if (!is.null(params$nhid))
    obj$nhid <- params$nhid
  if (!is.null(params$actfun))
    obj$actfun <- as.character(params$actfun)
  return(obj)
}

#'@import elmNNRcpp
#'@export
do_fit.ts_elm <- function(obj, x, y) {
  obj$model <- elmNNRcpp::elm_train(x, y, nhid = obj$nhid, actfun = obj$actfun, init_weights = "uniform_positive", bias = FALSE, verbose = FALSE)
  return(obj)
}

#'@import elmNNRcpp
#'@export
do_predict.ts_elm <- function(obj, x) {
  if (is.data.frame(x))
    x <- as.matrix(x)
  prediction <- elmNNRcpp::elm_predict(obj$model, x)
  return(prediction)
}
