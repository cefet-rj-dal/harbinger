test_that("hcp_waypoint detects confirmed change points", {
  skip_if_not_installed("daltoolbox")
  skip_if_not_installed("tspredit")

  data(examples_changepoints, package = "harbinger")
  dataset <- examples_changepoints$simple

  model <- hcp_waypoint(input_size = 12, encode_size = 4, warmup = 60)
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)

  expect_s3_class(detection, "data.frame")
  expect_true(all(c("idx", "event", "type") %in% names(detection)))
  expect_true(any(detection$type == "changepoint", na.rm = TRUE))
})

test_that("hcp_waypoint can use a real autoencoder when available", {
  skip_if_not_installed("daltoolbox")
  skip_if_not_installed("tspredit")
  skip_if_not_installed("daltoolboxdp")

  data(examples_changepoints, package = "harbinger")
  dataset <- examples_changepoints$simple

  model <- hcp_waypoint(
    input_size = 12,
    encode_size = 4,
    warmup = 60,
    encoderclass = daltoolboxdp::autoenc_ed
  )
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)

  expect_s3_class(detection, "data.frame")
  expect_true(any(detection$type == "changepoint", na.rm = TRUE))
})
