library(harbinger)

# Univariate example
data(examples_anomalies)
uni <- examples_anomalies$simple
har_plot(harbinger(), uni$serie, event = uni$event)

# Multivariate example from the 3W benchmark
data(oil_3w_Type_1)
oil_3w_Type_1 <- loadfulldata(oil_3w_Type_1)
first_mv <- oil_3w_Type_1[[1]]
meta_cols <- c("idx", "event", "type", "seq", "seqlen")
signal_cols <- setdiff(names(first_mv), meta_cols)
signal_cols

# Plot only the first signal column of the multivariate series
har_plot(
  harbinger(),
  first_mv[[signal_cols[1]]],
  event = first_mv$event
)
