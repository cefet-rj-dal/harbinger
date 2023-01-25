library(dplyr)
data(har_examples)
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

evaluation <- evaluate(model, detection$event, dataset$event, evaluation = soft_evaluation(sw=1))
print(evaluation$confMatrix)


