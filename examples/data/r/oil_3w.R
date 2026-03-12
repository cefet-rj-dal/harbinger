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

data(oil_3w_Type_1)
oil_3w_Type_1 <- loadfulldata(oil_3w_Type_1)
oil_type_1_info <- show_dataset(oil_3w_Type_1, "oil_3w_Type_1")

plot_dataset_preview(oil_type_1_info)

data(oil_3w_Type_2)
oil_3w_Type_2 <- loadfulldata(oil_3w_Type_2)
oil_type_2_info <- show_dataset(oil_3w_Type_2, "oil_3w_Type_2")

plot_dataset_preview(oil_type_2_info)

data(oil_3w_Type_4)
oil_3w_Type_4 <- loadfulldata(oil_3w_Type_4)
oil_type_4_info <- show_dataset(oil_3w_Type_4, "oil_3w_Type_4")

plot_dataset_preview(oil_type_4_info)

data(oil_3w_Type_5)
oil_3w_Type_5 <- loadfulldata(oil_3w_Type_5)
oil_type_5_info <- show_dataset(oil_3w_Type_5, "oil_3w_Type_5")

plot_dataset_preview(oil_type_5_info)

data(oil_3w_Type_6)
oil_3w_Type_6 <- loadfulldata(oil_3w_Type_6)
oil_type_6_info <- show_dataset(oil_3w_Type_6, "oil_3w_Type_6")

plot_dataset_preview(oil_type_6_info)

data(oil_3w_Type_7)
oil_3w_Type_7 <- loadfulldata(oil_3w_Type_7)
oil_type_7_info <- show_dataset(oil_3w_Type_7, "oil_3w_Type_7")

plot_dataset_preview(oil_type_7_info)

data(oil_3w_Type_8)
oil_3w_Type_8 <- loadfulldata(oil_3w_Type_8)
oil_type_8_info <- show_dataset(oil_3w_Type_8, "oil_3w_Type_8")

plot_dataset_preview(oil_type_8_info)
