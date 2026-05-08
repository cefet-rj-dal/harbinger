#' @title Plot Harbinger Ensemble Outputs
#' @description
#' Visualize ensemble detection results and the individual model votes stored
#' by `har_ensemble_fuzzy()`.
#'
#' The plotting helpers do not recompute detections. They use the attributes
#' attached to the detection object as the source of truth.
#'
#' @param detection A detection object returned by `detect.har_ensemble_fuzzy`.
#' @param serie Numeric vector with the original time series.
#' @param threshold Optional threshold override for the score panel.
#' @param time_idx Optional x-axis vector.
#' @return A `patchwork` object.
#'
#' @import ggplot2
#' @import patchwork
#' @export
har_ensemble_plot <- function(detection, serie, threshold = NULL, time_idx = NULL) {
  if (is.null(time_idx)) time_idx <- seq_along(serie)
  n <- length(serie)
  event <- detection$event
  if (is.null(event) || length(event) != n) event <- rep(FALSE, n)
  event <- as.logical(event)
  event[is.na(event)] <- FALSE
  score <- attr(detection, "score")
  if (is.null(score) || length(score) != n) score <- rep(0, n)
  score <- pmax(pmin(score, 1), 0)
  if (is.null(threshold)) threshold <- attr(detection, "threshold")
  if (!is.numeric(threshold) || length(threshold) != 1) threshold <- 0.5
  df <- data.frame(x_time = time_idx, x_value = serie, event = event, score = score)
  p1 <- ggplot2::ggplot(df, ggplot2::aes(x = rlang::.data$x_time, y = rlang::.data$score)) +
    ggplot2::geom_line(linewidth = 0.5, color = "black") +
    ggplot2::geom_hline(yintercept = threshold, linetype = "dashed", color = "red", linewidth = 0.5) +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.grid = ggplot2::element_blank()) +
    ggplot2::labs(title = "Ensemble Score", x = NULL, y = NULL)
  p2 <- ggplot2::ggplot(df, ggplot2::aes(x = rlang::.data$x_time, y = rlang::.data$x_value)) +
    ggplot2::geom_line(linewidth = 0.5, color = "black") +
    ggplot2::geom_point(size = 0.5, color = "black") +
    ggplot2::geom_point(data = df[df$event, ], color = "red", size = 2) +
    ggplot2::geom_vline(xintercept = df$x_time[df$event], linetype = "dashed", color = "red", linewidth = 0.5) +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.grid = ggplot2::element_blank()) +
    ggplot2::labs(title = "Detected Events", x = NULL, y = NULL)
  patchwork::wrap_plots(list(p1, p2), ncol = 1)
}

#' @title Plot individual model detections in a Harbinger fuzzy ensemble
#' @description
#' Visualizes the original series and the per-model detections stored in the
#' `model_events` attribute returned by `detect.har_ensemble_fuzzy()`.
#'
#' @param detection A detection object returned by `detect.har_ensemble_fuzzy`.
#' @param serie Numeric vector with the original time series.
#' @param time_idx Optional x-axis vector.
#' @return A `patchwork` object.
#'
#' @import ggplot2
#' @import patchwork
#' @export
har_ensemble_plot_models <- function(detection, serie, time_idx = NULL) {
  if (is.null(time_idx)) time_idx <- seq_along(serie)
  n <- length(serie)
  model_events <- attr(detection, "model_events")
  if (is.null(model_events)) {
    warning("model_events not found. Nothing to plot for individual models.")
    model_events <- list()
  }
  plots <- list()
  df_series <- data.frame(x_time = time_idx, x_value = serie)
  plots[[1]] <- ggplot2::ggplot(df_series, ggplot2::aes(x = rlang::.data$x_time, y = rlang::.data$x_value)) +
    ggplot2::geom_line(linewidth = 0.5, color = "black") +
    ggplot2::geom_point(size = 0.5) +
    ggplot2::theme_bw() +
    ggplot2::theme(panel.grid = ggplot2::element_blank()) +
    ggplot2::labs(title = "Original Series", x = "Time", y = "Value")
  for (i in seq_along(model_events)) {
    evt <- model_events[[i]]$raw
    if (is.null(evt) || length(evt) != n) evt <- rep(FALSE, n)
    event <- as.logical(evt)
    event[is.na(event)] <- FALSE
    df_model <- data.frame(x_time = time_idx, x_level = 0, event = event)
    model_name <- names(model_events)[i]
    if (is.null(model_name) || model_name == "") model_name <- paste0("model_", i)
    plots[[i + 1]] <- ggplot2::ggplot(df_model, ggplot2::aes(x = rlang::.data$x_time, y = rlang::.data$x_level)) +
      ggplot2::geom_line(color = "black", linewidth = 0.7) +
      ggplot2::geom_point(data = df_model[df_model$event, ], color = "red", size = 2) +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = ggplot2::element_text(family = "sans"),
        panel.grid = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      ) +
      ggplot2::ylab(model_name) +
      ggplot2::xlab(NULL) +
      ggplot2::theme(axis.title.y = ggplot2::element_text(angle = 0, size = 8, vjust = 0.5, hjust = 0.5))
  }
  patchwork::wrap_plots(plots, ncol = 1, heights = c(6, rep(1, length(plots) - 1)))
}
