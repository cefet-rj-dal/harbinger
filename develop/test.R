library(daltoolbox)

data(examples_anomalies)
dataset <- examples_anomalies$simple
head(dataset)

plot_ts(x = 1:length(dataset$serie), y = dataset$serie)

# fitting the model
model <- han_autoencoder(3, 2, autoenc_ed, num_epochs = 1500)

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

print(detection |> dplyr::filter(event==TRUE))

evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)

grf <- har_plot(model, dataset$serie, detection, dataset$event)

plot(grf)

res <-  attr(detection, "res")

plot(res)

