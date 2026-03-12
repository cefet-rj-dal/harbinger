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

data(nab_artificialWithAnomaly)
nab_artificialWithAnomaly <- loadfulldata(nab_artificialWithAnomaly)
nab_artificial_info <- show_dataset(nab_artificialWithAnomaly, "nab_artificialWithAnomaly")

plot_dataset_preview(nab_artificial_info)

data(nab_realAdExchange)
nab_realAdExchange <- loadfulldata(nab_realAdExchange)
nab_adexchange_info <- show_dataset(nab_realAdExchange, "nab_realAdExchange")

plot_dataset_preview(nab_adexchange_info)

data(nab_realAWSCloudwatch)
nab_realAWSCloudwatch <- loadfulldata(nab_realAWSCloudwatch)
nab_aws_info <- show_dataset(nab_realAWSCloudwatch, "nab_realAWSCloudwatch")

plot_dataset_preview(nab_aws_info)

data(nab_realKnownCause)
nab_realKnownCause <- loadfulldata(nab_realKnownCause)
nab_known_info <- show_dataset(nab_realKnownCause, "nab_realKnownCause")

plot_dataset_preview(nab_known_info)

data(nab_realTraffic)
nab_realTraffic <- loadfulldata(nab_realTraffic)
nab_traffic_info <- show_dataset(nab_realTraffic, "nab_realTraffic")

plot_dataset_preview(nab_traffic_info)

data(nab_realTweets)
nab_realTweets <- loadfulldata(nab_realTweets)
nab_tweets_info <- show_dataset(nab_realTweets, "nab_realTweets")

plot_dataset_preview(nab_tweets_info)
