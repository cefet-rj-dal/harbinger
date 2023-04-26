# DAL Library
# version 2.1

# depends dal_transform.R

### Categorical Mapping

#'@title Categorical Mapping
#'@description
#'@details
#'
#'@param attribute
#'@return
#'@examples
#'@export
categ_mapping <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("categ_mapping", class(obj))
  return(obj)
}

#'@export
transform.categ_mapping <- function(obj, data) {
  mdlattribute = formula(paste("~", paste(obj$attribute, "-1")))
  catmap <- model.matrix(mdlattribute, data=data)
  data <- cbind(data, catmap)
  return(data)
}
