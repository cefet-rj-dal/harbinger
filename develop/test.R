library(dplyr)
data(har_examples)

if (FALSE) {
  dataset <- har_examples[[1]]
  model <- fbiad(sw=30)
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}

if (FALSE) {
  dataset <- har_examples[[1]]
  model <- fbiad(sw=30)
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))

  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

  evaluation <- evaluate(model, detection$event, dataset$event, evaluation = soft_evaluation(sw=1))
  print(evaluation$confMatrix)

  detection[55, ] <- detection[50, ]
  detection[50, ] <- detection[1, ]

  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

  evaluation <- evaluate(model, detection$event, dataset$event, evaluation = soft_evaluation(sw=15))
  print(evaluation$confMatrix)
}

if (FALSE) {
  dataset <- har_examples[[4]]
  model <- change_point(sw=30)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)

  evaluation <- evaluate(model, detection$event, dataset$event, evaluation = soft_evaluation(sw=15))
  print(evaluation$confMatrix)
}

if (FALSE) {
  library(dplyr)
  library(harbinger)
  data(har_examples)

  dataset <- har_examples[[5]]
  model <- har_arima()
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}

if (TRUE) {
  library(dplyr)
  library(harbinger)
  data(har_examples)

  dataset <- har_examples[[4]]
  model <- har_garch()
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}

if (FALSE) {
  library(dplyr)
  data(har_examples)

  dataset <- har_examples[[4]]
  model <- change_finder_arima()
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}

if (FALSE) {
  library(dplyr)
  data(har_examples)

  dataset <- har_examples[[5]]
  model <- change_finder_ets()
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}






if (FALSE) {
  library(nnet)
  library(dplyr)
  library(harbinger)
  data(har_examples)

  dataset <- har_examples[[1]]

  model <- har_tsreg_sw(ts_mlp(ts_gminmax(), input_size=3, size=3, decay=0))
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}

if (TRUE) {
  library(nnet)
  library(dplyr)
  library(harbinger)
  data(har_examples)

  dataset <- har_examples[[1]]

  model <- har_tsreg_sw(ts_mlp(ts_ean(), input_size=8, size=10, decay=0), sw_size = 10)
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}

if (FALSE) {
  library(nnet)
  library(dplyr)
  library(harbinger)
  data(har_examples)

  dataset <- har_examples[[1]]

  model <- har_tsreg_sw(ts_mlp(ts_diff(), input_size=12, size=3, decay=0), sw_size = 15)
  model <- fit(model, dataset$serie)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot.harbinger(model, dataset$serie, detection)
  plot(grf)
  grf <- plot.harbinger(model, dataset$serie, detection, dataset$event)
  plot(grf)
}



