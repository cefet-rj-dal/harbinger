library(dplyr)
data(har_examples)
dataset <- har_examples[[1]]
model <- fbiad(sw=30, alpha=0.5)
x <- detect(model, dataset$serie)
print(x |> dplyr::filter(detection==TRUE))
evaluation <- evaluate(model, x$detection, dataset$event)
print(evaluation)
#plot()


#evaluation <- har_evaluation()
#evaluation <- evaluate(evaluation, c(1, 0, 1, 0), c(0, 0, 1, 0))
