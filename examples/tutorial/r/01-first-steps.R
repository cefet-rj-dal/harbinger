# Install Harbinger (if needed)
# install.packages("harbinger")

library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
head(dataset)

har_plot(harbinger(), dataset$serie, event = dataset$event)

model <- harbinger()

detection <- detect(model, dataset$serie)
head(detection)

har_plot(model, dataset$serie, detection, dataset$event)
