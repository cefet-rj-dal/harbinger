library(dplyr)
data(har_examples)

if (FALSE) {
  dataset <- har_examples[[1]]
  model <- fbiad(sw=30, alpha=0.5)
  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
  library(ggplot2)
  grf <- plot(model, dataset$serie, detection)
  plot(grf)
  grf <- plot(model, dataset$serie, detection, dataset$event)
  plot(grf)


  detection <- detect(model, dataset$serie)
  print(detection |> dplyr::filter(event==TRUE))
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)

  detection <- detect(model, dataset$serie)
  evaluation <- evaluate(model, detection$event, dataset$event, evaluation = soft_evaluation(sw=1))
  print(evaluation$confMatrix)

  detection <- detect(model, dataset$serie)
  detection[55, ] <- detection[50, ]
  detection[50, ] <- detection[1, ]
  evaluation <- evaluate(model, detection$event, dataset$event, evaluation = soft_evaluation(sw=15))
  print(evaluation$confMatrix)
}



dataset <- har_examples[[4]]
model <- change_point(sw=30, alpha=1.5)
detection <- detect(model, dataset$serie)
print(detection |> dplyr::filter(event==TRUE))
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
library(ggplot2)
grf <- plot(model, dataset$serie, detection)
plot(grf)
grf <- plot(model, dataset$serie, detection, dataset$event)
plot(grf)

