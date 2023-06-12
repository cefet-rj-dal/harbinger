# DAL Library
# version 2.1

# depends dal_transform.R

### Categorical Mapping

#'@title Categorical Mapping
#'@description The CategoricalMapping class in R provides a way to map the levels of a categorical variable to new values. It is often used to recode or reclassify categorical variables in data preprocessing and data analysis tasks.
#'@details The CategoricalMapping class has the following properties:
#'mapping: the named character vector that defines the mapping;
#'The CategoricalMapping class has the following methods:
#'map(x): maps the levels of a categorical variable x to new values based on the mapping;
#'summary(): provides a summary of the mapping, including the original and new levels.
#'
#'@param attribute The attribute representing the categorical variable.
#'@return An instance of the CategoricalMapping class.
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
  mdlattribute <- formula(paste("~", paste(obj$attribute, "-1")))
  catmap <- model.matrix(mdlattribute, data=data)
  data <- cbind(data, catmap)
  return(data)
}

