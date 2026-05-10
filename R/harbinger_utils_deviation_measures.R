is_matrix_or_df <- function(obj) {
  is.matrix(obj) || is.data.frame(obj)
}

har_deviation_l1 <- function(values) {
  values <- abs(values)
  if (is_matrix_or_df(values)) values <- rowSums(values)
  values
}

har_deviation_l2 <- function(values) {
  values <- values^2
  if (is_matrix_or_df(values)) values <- rowSums(values)
  values
}
