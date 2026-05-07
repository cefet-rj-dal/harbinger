#' @title Waypoint: adaptive change-point detection with autoencoder and CUSUM
#' @description
#' Implements the adaptive change-point detector described in the associated
#' SBBD article: a non-supervised autoencoder learns a reference regime from
#' temporal windows, the reconstruction error is standardized on a recent
#' buffer, and a bilateral CUSUM supervisor validates persistent deviations.
#' When a change is confirmed, the model is retrained on recent data and the
#' supervisor is reset.
#'
#' @details
#' The method separates representation and decision:
#' - the autoencoder reconstructs windows and produces a scalar reconstruction error;
#' - the error is standardized with a rolling buffer;
#' - a bilateral CUSUM with lower and upper thresholds (`h_low`, `h_high`) acts
#'   as the statistical supervisor;
#' - after confirmation, the autoencoder is retrained on the most recent regime.
#'
#' This detector is intended for regime-change monitoring rather than isolated
#' anomaly marking.
#'
#' @param input_size Integer. Window size used to build autoencoder samples.
#' @param encode_size Integer. Latent size for the autoencoder.
#' @param warmup Integer. Number of leading observations used to initialize the model.
#' @param retrain_size Integer. Number of recent observations used when retraining after a confirmed change.
#' @param buffer_size Integer. Number of previous residuals used to standardize the current reconstruction error.
#' @param k_factor Numeric. CUSUM reference value (`k`).
#' @param h_low Numeric. Warning threshold for the bilateral CUSUM supervisor.
#' @param h_high Numeric. Confirmation threshold for the bilateral CUSUM supervisor.
#' @param prob_tau Numeric. Quantile used to estimate the residual threshold from the warm-up regime.
#' @param epochs_init Integer. Epochs for the initial autoencoder training.
#' @param epochs_retrain Integer. Epochs for retraining after a confirmed change.
#' @param encoderclass DALToolbox autoencoder constructor. Defaults to `autoenc_base_ed`.
#' @param ... Additional arguments forwarded to `encoderclass`; these are
#'   the autoencoder-specific parameters, not `hcp_waypoint` parameters.
#'
#' @return `hcp_waypoint` object.
#'
#' @references
#' - Ogasawara, E., Salles, R., Porto, F., Pacitti, E. (2025). *Event Detection in Time Series*.
#' - Salles, R. et al. (2020). Harbinger: Um framework para integração e análise de métodos de detecção de eventos em séries temporais. SBBD.
#' - Ygorra, B. et al. (2021). Monitoring loss of tropical forest cover from Sentinel-1 time-series: A CuSum-based approach.
#' - Ygorra, B. et al. (2024). A near-real-time tropical deforestation monitoring algorithm based on the CuSum change detection method.
#' - De Ryck, T. et al. (2021). Change Point Detection in Time Series Data Using Autoencoders with a Time-Invariant Representation.
#' - Cao, Z. et al. (2024). Change Point Detection in Multi-Channel Time Series via a Time-Invariant Representation.
#' - Corizzo, R. et al. (2022). CPDGA: Change point driven growing auto-encoder for lifelong anomaly detection.
#'
#' @examples
#' library(daltoolbox)
#'
#' data(examples_changepoints)
#' dataset <- examples_changepoints$simple
#'
#' model <- hcp_waypoint(input_size = 12, encode_size = 4)
#' model <- fit(model, dataset$serie)
#' detection <- detect(model, dataset$serie)
#' print(detection[detection$event, ])
#'
#' @importFrom daltoolbox autoenc_base_ed
#' @export
hcp_waypoint <- function(input_size, encode_size,
                         warmup = 500,
                         retrain_size = 300,
                         buffer_size = 100,
                         k_factor = 0.35,
                         h_low = 3.5,
                         h_high = 6,
                         prob_tau = 0.997,
                         epochs_init = 40,
                         epochs_retrain = 20,
                         encoderclass = autoenc_base_ed, ...) {
  obj <- harbinger()
  obj$input_size <- input_size
  obj$encode_size <- encode_size
  obj$warmup <- warmup
  obj$retrain_size <- retrain_size
  obj$buffer_size <- buffer_size
  obj$k_factor <- k_factor
  obj$h_low <- h_low
  obj$h_high <- h_high
  obj$prob_tau <- prob_tau
  obj$epochs_init <- epochs_init
  obj$epochs_retrain <- epochs_retrain
  obj$model <- encoderclass(obj$input_size, obj$encode_size, ...)
  obj$preproc <- tspredit::ts_norm_gminmax()
  class(obj) <- append("hcp_waypoint", class(obj))
  return(obj)
}

#' @importFrom daltoolbox fit
#' @importFrom daltoolbox transform
#' @importFrom tspredit ts_data
#' @exportS3Method fit hcp_waypoint
fit.hcp_waypoint <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  train_serie <- obj$serie
  if (length(train_serie) > obj$warmup) {
    train_serie <- train_serie[seq_len(obj$warmup)]
  }

  ts <- tspredit::ts_data(train_serie, obj$input_size)
  if (is.null(ts) || nrow(ts) == 0) {
    return(obj)
  }

  obj$preproc <- daltoolbox::fit(obj$preproc, ts)
  ts <- as.data.frame(daltoolbox::transform(obj$preproc, ts))
  obj$model <- daltoolbox::fit(obj$model, ts, epochs = obj$epochs_init, ...)

  return(obj)
}

#' @importFrom daltoolbox transform
#' @importFrom tspredit ts_data
#' @exportS3Method detect hcp_waypoint
detect.hcp_waypoint <- function(obj, serie, ...) {
  if (is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  if (is.null(obj$model)) {
    obj <- fit(obj, obj$serie, ...)
  }

  n <- length(obj$serie)
  results_mse <- rep(NA_real_, n)
  results_tau <- rep(NA_real_, n)
  results_drift <- rep(FALSE, n)
  drift_indices <- integer()
  pos <- 0
  neg <- 0
  last_retrain <- min(obj$warmup, n)

  initial_end <- min(obj$warmup, n)
  train_data <- obj$serie[seq_len(initial_end)]
  ts_train <- tspredit::ts_data(train_data, obj$input_size)
  if (is.null(ts_train) || nrow(ts_train) == 0) {
    return(obj$har_restore_refs(obj, change_points = results_drift, res = results_mse))
  }

  ts_train_n <- as.data.frame(daltoolbox::transform(obj$preproc, ts_train))
  rec_train <- as.data.frame(daltoolbox::transform(obj$model, ts_train_n))
  mse_train <- rowMeans((as.matrix(ts_train_n) - as.matrix(rec_train))^2)
  tau <- stats::quantile(mse_train, probs = obj$prob_tau, na.rm = TRUE)

  start_t <- max(initial_end, obj$input_size) + 1
  if (start_t > n) {
    res <- c(rep(NA_real_, obj$input_size - 1), results_mse[seq_len(n)])
    detection <- obj$har_restore_refs(obj, change_points = results_drift, res = res)
    attr(detection, "tau") <- tau
    return(detection)
  }

  for (t in start_t:n) {
    win <- obj$serie[(t - obj$input_size + 1):t]
    win_df <- as.data.frame(t(win))
    win_n <- as.data.frame(daltoolbox::transform(obj$preproc, win_df))
    rec <- as.data.frame(daltoolbox::transform(obj$model, win_n))
    mse_t <- mean((as.matrix(win_n) - as.matrix(rec))^2)

    results_mse[t] <- mse_t
    results_tau[t] <- tau

    if (t > last_retrain + 50) {
      buffer_start <- max(1, t - obj$buffer_size)
      buffer <- stats::na.omit(results_mse[buffer_start:(t - 1)])

      if (length(buffer) > 20 && stats::sd(buffer) > 0) {
        z <- (mse_t - mean(buffer)) / (stats::sd(buffer) + 1e-5)

        pos <- max(0, pos + z - obj$k_factor)
        neg <- min(0, neg + z + obj$k_factor)

        warning_flag <- (pos > obj$h_low) || (neg < -obj$h_low)
        drift_flag <- (pos > obj$h_high) || (neg < -obj$h_high)

        if (warning_flag) {
          results_tau[t] <- tau
        }

        if (drift_flag && (t - last_retrain > obj$retrain_size)) {
          results_drift[t] <- TRUE
          drift_indices <- c(drift_indices, t)

          retrain_start <- max(1, t - obj$retrain_size + 1)
          new_data <- obj$serie[retrain_start:t]
          ts_new <- tspredit::ts_data(new_data, obj$input_size)

          if (!is.null(ts_new) && nrow(ts_new) > 0) {
            obj$preproc <- daltoolbox::fit(tspredit::ts_norm_gminmax(), ts_new)
            ts_new_n <- as.data.frame(daltoolbox::transform(obj$preproc, ts_new))
            obj$model <- daltoolbox::fit(obj$model, ts_new_n, epochs = obj$epochs_retrain, ...)

            rec_new <- as.data.frame(daltoolbox::transform(obj$model, ts_new_n))
            mse_new <- rowMeans((as.matrix(ts_new_n) - as.matrix(rec_new))^2)
            tau <- stats::quantile(mse_new, probs = obj$prob_tau, na.rm = TRUE)
          }

          pos <- 0
          neg <- 0
          last_retrain <- t
        }
      }
    }
  }

  res <- c(rep(NA_real_, obj$input_size - 1), results_mse[seq_len(n)])
  cp <- results_drift
  attr(cp, "threshold") <- tau
  attr(cp, "drift_indices") <- drift_indices

  detection <- obj$har_restore_refs(obj, change_points = cp, res = res)
  attr(detection, "tau") <- tau
  attr(detection, "drift_indices") <- drift_indices
  return(detection)
}
