 suppressWarnings(suppressPackageStartupMessages(library(daltoolbox)))

source(file.path("..", "..", "R", "harbinger.R"))
source(file.path("..", "..", "R", "harbinger_utils.R"))
source(file.path("..", "..", "R", "har_ensemble.R"))
source(file.path("..", "..", "R", "har_ensemble_fuzzy.R"))
source(file.path("..", "..", "R", "har_plot_ensemble.R"))
source(file.path("..", "..", "R", "hcp_bocpd.R"))

make_dummy_detector <- function(event, type = "anomaly") {
  obj <- harbinger()
  obj$event <- event
  obj$type <- type
  class(obj) <- append("dummy_detector", class(obj))
  obj
}

fit.dummy_detector <- function(obj, serie, ...) {
  obj$serie <- serie
  obj
}

detect.dummy_detector <- function(obj, serie, ...) {
  n <- length(serie)
  event <- obj$event
  if (length(event) != n) event <- rep(FALSE, n)
  type <- obj$type
  if (length(type) != n) type <- rep(type, n)
  data.frame(
    idx = seq_len(n),
    event = event,
    type = type,
    stringsAsFactors = FALSE
  )
}

test_that("har_ensemble uses strict majority vote", {
  res <- c(2, 1, 3)
  events <- res > 3 / 2
  expect_identical(events, c(TRUE, FALSE, TRUE))
})

test_that("har_outliers_ratio handles zero and empty vectors", {
  empty <- har_outliers_ratio(numeric(0))
  expect_length(empty, 0)

  zeros <- har_outliers_ratio(c(0, 0, 0))
  expect_length(zeros, 0)
})

test_that("har_ensemble_fuzzy returns score attributes and plots", {
  serie <- 1:5
  model <- har_ensemble_fuzzy(
    make_dummy_detector(c(TRUE, FALSE, FALSE, FALSE, FALSE)),
    make_dummy_detector(c(TRUE, TRUE, FALSE, FALSE, FALSE))
  )
  model <- fit.har_ensemble_fuzzy(model, serie)
  detection <- detect.har_ensemble_fuzzy(model, serie, time_tolerance = 2, use_nms = TRUE)

  expect_s3_class(detection, "data.frame")
  expect_true(all(c("score", "threshold", "model_events") %in% names(attributes(detection))))
  expect_true(is.list(attr(detection, "model_events")))
  expect_s3_class(har_ensemble_plot(detection, serie), "patchwork")
  expect_s3_class(har_ensemble_plot_models(detection, serie), "patchwork")
})

test_that("hcp_bocpd constructor is available and namespaced", {
  model <- hcp_bocpd()
  expect_s3_class(model, "hcp_bocpd")
})
