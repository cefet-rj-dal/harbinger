library(harbinger)

dataset_summary <- function(x) {
  first_series <- x[[1]]
  meta_cols <- c("idx", "event", "type", "seq", "seqlen")
  signal_cols <- setdiff(names(first_series), meta_cols)
  dataset_type <- if ("value" %in% names(first_series) || length(signal_cols) == 1) "univariate" else "multivariate"
  plot_column <- if ("value" %in% names(first_series)) "value" else signal_cols[1]

  list(
    n_series = length(x),
    dataset_type = dataset_type,
    signal_cols = signal_cols,
    plot_column = plot_column,
    preview_size = min(1000, nrow(first_series)),
    first_series = first_series
  )
}

show_dataset <- function(x, name) {
  info <- dataset_summary(x)
  cat("Dataset:", name, "\n")
  cat("Number of series:", info$n_series, "\n")
  cat("Dataset type:", info$dataset_type, "\n")
  cat("Signals in the first series:", paste(info$signal_cols, collapse = ", "), "\n")
  cat("Column plotted with har_plot():", info$plot_column, "\n")
  cat("Plot preview length:", info$preview_size, "observations\n")
  invisible(info)
}

plot_dataset_preview <- function(info) {
  preview <- info$first_series[seq_len(info$preview_size), , drop = FALSE]
  har_plot(
    harbinger(),
    preview[[info$plot_column]],
    event = preview$event
  )
}

data(mit_bih_MLII)
mit_bih_MLII <- loadfulldata(mit_bih_MLII)
mit_mlii_info <- show_dataset(mit_bih_MLII, "mit_bih_MLII")

plot_dataset_preview(mit_mlii_info)

data(mit_bih_V1)
mit_bih_V1 <- loadfulldata(mit_bih_V1)
mit_v1_info <- show_dataset(mit_bih_V1, "mit_bih_V1")

plot_dataset_preview(mit_v1_info)

data(mit_bih_V2)
mit_bih_V2 <- loadfulldata(mit_bih_V2)
mit_v2_info <- show_dataset(mit_bih_V2, "mit_bih_V2")

plot_dataset_preview(mit_v2_info)

data(mit_bih_V5)
mit_bih_V5 <- loadfulldata(mit_bih_V5)
mit_v5_info <- show_dataset(mit_bih_V5, "mit_bih_V5")

plot_dataset_preview(mit_v5_info)
