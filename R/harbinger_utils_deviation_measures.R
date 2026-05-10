is_matrix_or_df <- function(obj) {
  is.matrix(obj) || is.data.frame(obj)
}

har_huber_rho <- function(values, k) {
  abs_values <- abs(values)
  ifelse(abs_values <= k, 0.5 * values^2, k * (abs_values - 0.5 * k))
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

har_deviation_huber <- function(values, k = 1.345) {
  values <- har_huber_rho(values, k = k)
  if (is_matrix_or_df(values)) values <- rowSums(values)
  values
}
