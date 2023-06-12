# DAL Library
# version 2.1

# depends dal_transform.R

### PCA
#'@title PCA
#'@description PCA (Principal Component Analysis) is a commonly used unsupervised dimensionality reduction technique in data analysis and machine learning. It is used to transform a dataset of possibly correlated variables into a new set of uncorrelated variables called principal components.
#'@details The prcomp() function returns an object of class prcomp, which contains the following components: sdev: the standard deviations of the principal components; rotation: the matrix of variable loadings (the eigenvectors of the covariance matrix); center: the centering values used, if any; scale: the scaling values used, if any; x: the centered and optionally scaled data matrix; rank: the rank of the data matrix; call: the function call used to generate the result; na.action: the method used to handle missing values, if any
#'
#'@param attribute
#'@param components
#'@return
#'@examples
#'@export
dt_pca <- function(attribute=NULL, components = NULL) {
  obj <- dal_transform()
  obj$attribute <- attribute
  obj$components <- components
  class(obj) <- append("dt_pca", class(obj))
  return(obj)
}

#'@export
fit.dt_pca <- function(obj, data) {
  data <- data.frame(data)
  attribute <- obj$attribute
  if (!is.null(attribute)) {
    data[,attribute] <- NULL
  }
  nums <- unlist(lapply(data, is.numeric))
  remove <- NULL
  for(j in names(nums[nums])) {
    if(min(data[,j])==max(data[,j]))
      remove <- cbind(remove, j)
  }
  nums[remove] <- FALSE
  data = as.matrix(data[ , nums])

  pca_res <- prcomp(data, center=TRUE, scale.=TRUE)

  if (is.null(obj$components)) {
    y <-  cumsum(pca_res$sdev^2/sum(pca_res$sdev^2))
    curv <-  fit_curvature_min()
    res <- transform(curv, y)
    obj$components <- res$x

  }

  obj$pca.transf <- as.matrix(pca_res$rotation[, 1:obj$components])
  obj$nums <- nums

  return(obj)
}

#'@export
transform.dt_pca <- function(obj, data) {
  attribute <- obj$attribute
  pca.transf <- obj$pca.transf
  nums <- obj$nums

  data <- data.frame(data)
  if (!is.null(attribute)) {
    predictand <- data[,attribute]
    data[,attribute] <- NULL
  }
  data = as.matrix(data[ , nums])

  data = data %*% pca.transf
  data = data.frame(data)
  if (!is.null(attribute)){
    data[,attribute] <- predictand
  }
  return(data)
}
